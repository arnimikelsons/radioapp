defmodule RadioappWeb.TimeslotController do
  use RadioappWeb, :controller

  alias Radioapp.Station
  alias Radioapp.Station.{Timeslot}
  alias Radioapp.Admin 

  def index(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    timeslots = Station.list_timeslots(tenant)
    current_user = conn.assigns.current_user
    current_role = if current_user != nil do
      case Map.get(current_user.roles, tenant) do
        nil -> Map.get(current_user.roles, "admin")
        _ -> Map.get(current_user.roles, tenant)
      end
    end
    render(conn, :index, timeslots: timeslots, current_user: current_user, current_role: current_role)
  end

  def index_by_day(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    timeslots_by_day = Station.list_timeslots_by_day(id, tenant)
    day = String.to_integer(id)
    current_user = conn.assigns.current_user
    current_role = if current_user != nil do
      case Map.get(current_user.roles, tenant) do
        nil -> Map.get(current_user.roles, "admin")
        _ -> Map.get(current_user.roles, tenant)
      end
    end
    render(conn, :schedule, timeslots_by_day: timeslots_by_day, day: day, current_user: current_user, current_role: current_role, tenant: tenant)
  end

  def index_by_day(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    %{timezone: timezone} = Admin.get_stationdefaults!(tenant)
    now = DateTime.to_naive(Timex.now(timezone))
    day = Timex.weekday(now)

    timeslots_by_day = Station.list_timeslots_by_day(day, tenant)
    current_user = conn.assigns.current_user
    current_role = if current_user != nil do
      case Map.get(current_user.roles, tenant) do
        nil -> Map.get(current_user.roles, "admin")
        _ -> Map.get(current_user.roles, tenant)
      end
    end
    render(conn, :schedule_orig, timeslots_by_day: timeslots_by_day, day: day, current_user: current_user, current_role: current_role)
  end



  def new(conn, %{"program_id" => program_id}) do
    tenant = RadioappWeb.get_tenant(conn)
    program = Station.get_program!(program_id, tenant)

    changeset = Station.change_timeslot(%Timeslot{})
    render(conn, :new, program: program, changeset: changeset)
  end

  def create(conn, %{"program_id" => program_id, "timeslot" => timeslot_params}) do
    tenant = RadioappWeb.get_tenant(conn)
    program = Station.get_program!(program_id, tenant)

    case Station.create_timeslot(program, timeslot_params, tenant) do
      {:ok, _timeslot} ->
        conn
        |> put_flash(:info, "Timeslot created successfully.")
        |> redirect(to: ~p"/programs/#{program}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, program: program, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    timeslot = Station.get_timeslot!(id, tenant)
    program = Station.get_program!(timeslot.program_id, tenant)
    render(conn, :show, timeslot: timeslot, program: program)
  end

  def edit(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    timeslot = Station.get_timeslot!(id, tenant)
    program = Station.get_program!(timeslot.program_id, tenant)
    changeset = Station.change_timeslot(timeslot)
    render(conn, :edit, program: program, timeslot: timeslot, changeset: changeset)
  end

  def update(conn, %{"id" => id, "timeslot" => timeslot_params}) do
    tenant = RadioappWeb.get_tenant(conn)
    timeslot = Station.get_timeslot!(id, tenant)
    program = Station.get_program!(timeslot.program_id, tenant)

    case Station.update_timeslot(timeslot, timeslot_params) do
      {:ok, _timeslot} ->
        conn
        |> put_flash(:info, "Timeslot updated successfully.")
        |> redirect(to: ~p"/programs/#{program}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, program: program, timeslot: timeslot, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    timeslot = Station.get_timeslot!(id, tenant)
    program = Station.get_program!(timeslot.program_id, tenant)

    {:ok, _timeslot} = Station.delete_timeslot(timeslot)

    conn
    |> put_flash(:info, "Timeslot deleted successfully.")
    |> redirect(to: ~p"/programs/#{program}")
  end
end
