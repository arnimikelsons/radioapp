defmodule RadioappWeb.TimeslotController do
  use RadioappWeb, :controller

  alias Radioapp.Station
  alias Radioapp.Station.{Timeslot}

  def index(conn, _params) do
    timeslots = Station.list_timeslots()
    current_user = conn.assigns.current_user
    render(conn, :index, timeslots: timeslots, current_user: current_user)
  end

  def index_by_day(conn, %{"id" => id}) do
    timeslots_by_day = Station.list_timeslots_by_day(id)
    day =  String.to_integer(id)
    current_user = conn.assigns.current_user
    render(conn, :schedule, timeslots_by_day: timeslots_by_day, day: day, current_user: current_user)
  end

  def index_by_day(conn, _params) do
    now = DateTime.to_naive(Timex.now("America/Toronto"))
    day = Timex.weekday(now)

    timeslots_by_day = Station.list_timeslots_by_day(day)
    current_user = conn.assigns.current_user
    render(conn, :schedule_orig, timeslots_by_day: timeslots_by_day, day: day, current_user: current_user)
  end



  def new(conn, %{"program_id" => program_id}) do
    program = Station.get_program!(program_id)

    changeset = Station.change_timeslot(%Timeslot{})
    render(conn, :new, program: program, changeset: changeset)
  end

  def create(conn, %{"program_id" => program_id, "timeslot" => timeslot_params}) do
    program = Station.get_program!(program_id)

    case Station.create_timeslot(program, timeslot_params) do
      {:ok, _timeslot} ->
        conn
        |> put_flash(:info, "Timeslot created successfully.")
        |> redirect(to: ~p"/programs/#{program}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, program: program, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    timeslot = Station.get_timeslot!(id)
    program = Station.get_program!(timeslot.program_id)
    render(conn, :show, timeslot: timeslot, program: program)
  end

  def edit(conn, %{"id" => id}) do
    timeslot = Station.get_timeslot!(id)
    program = Station.get_program!(timeslot.program_id)
    changeset = Station.change_timeslot(timeslot)
    render(conn, :edit, program: program, timeslot: timeslot, changeset: changeset)
  end

  def update(conn, %{"id" => id, "timeslot" => timeslot_params}) do
    timeslot = Station.get_timeslot!(id)
    program = Station.get_program!(timeslot.program_id)

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
    timeslot = Station.get_timeslot!(id)
    program = Station.get_program!(timeslot.program_id)

    {:ok, _timeslot} = Station.delete_timeslot(timeslot)

    conn
    |> put_flash(:info, "Timeslot deleted successfully.")
    |> redirect(to: ~p"/programs/#{program}")
  end
end
