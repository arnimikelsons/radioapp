defmodule RadioappWeb.LogLive.Index do
  use RadioappWeb, :live_view

  alias Radioapp.Station
  alias Radioapp.Station.Log
  import RadioappWeb.LiveHelpers

  @impl true
  def mount(%{
    "program_id" => program_id
    }, session, socket) do

    socket =
      assign_defaults(session, socket)

    program = Station.get_program!(program_id)
    {:ok,
      socket
      |> assign(:logs, list_logs_for_program(program))}

  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, %{
    "program_id" => program_id
  }) do
    program = Station.get_program!(program_id)

    socket
    |> assign(:page_title, "New Log")
    |> assign(:program, program)
    |> assign(:log, %Log{})
  end

  defp apply_action(socket, :edit, %{
    "id" => id,
    "program_id" => program_id
    }) do

    program = Station.get_program!(program_id)

    socket
    |> assign(:page_title, "Edit Log")
    |> assign(:program, program)
    |> assign(:log, Station.get_log!(id))
  end



  defp apply_action(socket, :index, %{
    "program_id" => program_id
  }) do
    program = Station.get_program!(program_id)

    socket
    |> assign(:page_title, "Logs")
    |> assign(:program, program)
    |> assign(:segment, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    log = Station.get_log!(id)
    program = Station.get_program!(log.program_id)
    if socket.assigns.current_user.role == :admin do
      {:ok, _} = Station.delete_log(log)
    end
    {:noreply, assign(socket, :logs, list_logs_for_program(program))}

  end

  defp list_logs_for_program(program) do
    Station.list_logs_for_program(program)
  end

end
