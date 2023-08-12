defmodule RadioappWeb.ProgramController do
  use RadioappWeb, :controller

  alias Radioapp.Station
  alias Radioapp.Station.{Program, Image}
  alias Radioapp.Admin

  def index(conn, _params) do
    programs = Station.list_programs()
    all_programs = Station.list_all_programs()
    current_user = conn.assigns.current_user
    render(conn, :index, programs: programs, all_programs: all_programs, current_user: current_user)
  end

  def new(conn, _params) do
    changeset = Station.change_program(%Program{})
    list_links = [{"", nil} | Admin.list_links_dropdown()]
    render(conn, :new, changeset: changeset, list_links: list_links)
  end

  def create(conn, %{"program" => program_params}) do
    case Station.create_program(program_params) do
      {:ok, program} ->
        conn
        |> put_flash(:info, "Program created successfully.")
        |> redirect(to: ~p"/programs/#{program}")

      {:error, %Ecto.Changeset{} = changeset} ->
        list_links = Admin.list_links_dropdown()
        render(conn, :new, changeset: changeset, list_links: list_links)
    end
  end

  def show(conn, %{"id" => id}) do
    program = Station.get_program!(id)
    timeslots = Station.list_timeslots_for_program(program)
    image =
    case program.images do
      %Image{} = image ->
        image
        |> Image.changeset(%{})

      nil ->
        %Image{}
        |> Image.changeset(%{})
    end

    render(conn, :show, timeslots: timeslots, program: program, image: image)
  end

  def edit(conn, %{"id" => id}) do
    program = Station.get_program!(id)
    list_links = [{"", nil} | Admin.list_links_dropdown()]
    changeset = Station.change_program(program)
    render(conn, :edit, program: program, changeset: changeset, list_links: list_links)
  end

  def update(conn, %{"id" => id, "program" => program_params}) do
    program = Station.get_program!(id)

    case Station.update_program(program, program_params) do
      {:ok, program} ->
        conn
        |> put_flash(:info, "Program updated successfully.")
        |> redirect(to: ~p"/programs/#{program}")

      {:error, %Ecto.Changeset{} = changeset} ->
        list_links = Admin.list_links_dropdown()
        render(conn, :edit, program: program, changeset: changeset, list_links: list_links)
    end
  end

  def delete(conn, %{"id" => id}) do
    program = Station.get_program!(id)
    {:ok, _program} = Station.delete_program(program)

    conn
    |> put_flash(:info, "Program deleted successfully.")
    |> redirect(to: ~p"/programs")
  end
end
