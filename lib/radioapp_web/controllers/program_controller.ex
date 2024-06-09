defmodule RadioappWeb.ProgramController do
  use RadioappWeb, :controller

  alias Radioapp.Station
  alias Radioapp.Station.{Program, Image}
  alias Radioapp.Admin

  def index(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    programs = Station.list_programs(tenant)
    all_programs = Station.list_all_programs(tenant)
    current_user = conn.assigns.current_user
    render(conn, :index, programs: programs, all_programs: all_programs, current_user: current_user)
  end

  def new(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    changeset = Station.change_program(%Program{})
    list_links = [{"", nil} | Admin.list_links_dropdown(tenant)]
    render(conn, :new, changeset: changeset, list_links: list_links)
  end

  def create(conn, %{"program" => program_params}) do
    tenant = RadioappWeb.get_tenant(conn)

    case Station.create_program(program_params, tenant) do
      {:ok, program} ->
        conn
        |> put_flash(:info, "Program created successfully.")
        |> redirect(to: ~p"/programs/#{program}")

      {:error, %Ecto.Changeset{} = changeset} ->
        list_links = Admin.list_links_dropdown(tenant)
        render(conn, :new, changeset: changeset, list_links: list_links)
    end
  end

  def show(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    program = Station.get_program!(id, tenant)
    timeslots = Station.list_timeslots_for_program(program, tenant)
    image =
    case program.images do
      %Image{} = image ->
        image
        |> Image.changeset(%{})

      nil ->
        %Image{}
        |> Image.changeset(%{})
    end
    user = conn.assigns.current_user

    cols = case program.images do
      nil -> if user do "md:w-1/2" else "w-full" end
      _ -> "md:w-1/2"
    end
    
    user_role = if user != nil do
      
      case Map.get(user.roles, tenant) do
        nil -> Map.get(user.roles, "admin")
        _ -> Map.get(user.roles, tenant)
      end
    end

    render(conn, :show, timeslots: timeslots, program: program, image: image, user_role: user_role, cols: cols)
  end

  def edit(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    program = Station.get_program!(id, tenant)
    list_links = [{"", nil} | Admin.list_links_dropdown(tenant)]
    changeset = Station.change_program(program)
    render(conn, :edit, program: program, changeset: changeset, list_links: list_links)
  end

  def update(conn, %{"id" => id, "program" => program_params}) do
    tenant = RadioappWeb.get_tenant(conn)
    program = Station.get_program!(id, tenant)

    case Station.update_program(program, program_params) do
      {:ok, program} ->
        conn
        |> put_flash(:info, "Program updated successfully.")
        |> redirect(to: ~p"/programs/#{program}")

      {:error, %Ecto.Changeset{} = changeset} ->
        list_links = Admin.list_links_dropdown(tenant)
        render(conn, :edit, program: program, changeset: changeset, list_links: list_links)
    end
  end

  def delete(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    program = Station.get_program!(id, tenant)
    {:ok, _program} = Station.delete_program(program)

    conn
    |> put_flash(:info, "Program deleted successfully.")
    |> redirect(to: ~p"/programs")
  end
end
