defmodule RadioappWeb.PlayoutSegmentLive.Index do
  use RadioappWeb, :live_view

  alias Radioapp.Station
  # alias Radioapp.Station.PlayoutSegment
  alias Radioapp.Admin
  import RadioappWeb.LiveHelpers

  @impl true
  def mount(
        _params,
        session,
        socket
      ) do
    tenant = Map.fetch!(session, "subdomain")
    socket =
      assign_stationdefaults(session, socket)
      |> assign(:tenant, tenant)

    current_role = socket.assigns.current_user.role

    playout_segments = Station.list_playout_segments(tenant)

    {:ok,
     assign(socket,
       playout_segments: playout_segments,
       current_role: current_role,
       tenant: tenant
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # defp apply_action(socket, :new, %{
  #        "program_id" => program_id,
  #        "log_id" => log_id
  #      }) do
  #   tenant = socket.assigns.tenant
  #   program = Station.get_program!(program_id, tenant)
  #   log = Station.get_log!(log_id, tenant)
  #   list_categories = Admin.list_categories_dropdown(tenant)

  #   socket
  #   |> assign(:page_title, "New Segment")
  #   |> assign(:program, program)
  #   |> assign(:log, log)
  #   |> assign(:list_categories, list_categories)
  #   |> assign(:playout_segment, %PlayoutSegment{})
  # end

  defp apply_action(socket, :edit, %{"id" => id}) do
    tenant = socket.assigns.tenant
    list_categories = Admin.list_categories_dropdown(tenant)

    socket
    |> assign(:page_title, "Edit Playout Segment")
    |> assign(:list_categories, list_categories)
    |> assign(:playout_segment, Station.get_playout_segment!(id, tenant))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Segments from Playout System")
    |> assign(:playout_segment, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tenant = socket.assigns.tenant
    segment = Station.get_segment!(id, tenant)
    if socket.assigns.current_user.role == :admin do
      {:ok, _} = Station.delete_segment(segment)
    end

    {:noreply, assign(socket, :segments, list_playout_segments(tenant))}
  end

  defp list_playout_segments(tenant) do
    Station.list_playout_segments(tenant)
  end
end
