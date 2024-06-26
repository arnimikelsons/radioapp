defmodule RadioappWeb.LogLive.Index do
  use RadioappWeb, :live_view

  alias Radioapp.Station
  alias Radioapp.Station.Log
  import RadioappWeb.LiveHelpers
  alias Radioapp.Admin

  @impl true
  def mount(%{
    "program_id" => program_id
    }, session, socket) do
    tenant = Map.fetch!(session, "subdomain")

    socket =
      assign_stationdefaults(session, socket)
      |> assign(:tenant, tenant)
      |> assign(:timezone, Admin.get_timezone!(tenant))

    program = Station.get_program!(program_id, tenant)
    {:ok,
      socket
      |> assign(:logs, list_logs_for_program(program, tenant))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, %{
    "program_id" => program_id
  }) do

    tenant = socket.assigns.tenant
    program = Station.get_program!(program_id, tenant)

    socket
    |> assign(:page_title, "New Log")
    |> assign(:program, program)
    |> assign(:log, %Log{})


  end

  defp apply_action(socket, :edit, %{
    "id" => id,
    "program_id" => program_id
    }) do
    tenant = socket.assigns.tenant
    program = Station.get_program!(program_id, tenant)

    socket
    |> assign(:page_title, "Edit Log")
    |> assign(:program, program)
    |> assign(:log, Station.get_log!(id, tenant))
    |> assign(:tenant, tenant)
  end



  defp apply_action(socket, :index, %{
    "program_id" => program_id
  }) do
    tenant = socket.assigns.tenant
    program = Station.get_program!(program_id, tenant)

    # DateTime.shift_zone(datetime, time_zone, time_zone_database \\ Calendar.get_time_zone_database())
    socket
    |> assign(:page_title, "Logs")
    |> assign(:program, program)
    |> assign(:segment, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tenant = socket.assigns.tenant
    log = Station.get_log!(id, tenant)
    program = Station.get_program!(log.program_id, tenant)

    {:ok, _} = Station.delete_log(log)

    {:noreply, assign(socket, :logs, list_logs_for_program(program, tenant))}
  end

  defp list_logs_for_program(program, tenant) do
    Station.list_logs_for_program(program, tenant)
  end



end
