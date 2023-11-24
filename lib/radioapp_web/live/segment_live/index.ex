defmodule RadioappWeb.SegmentLive.Index do
  use RadioappWeb, :live_view

  alias Radioapp.Station
  alias Radioapp.Station.Segment
  alias Radioapp.Admin
  import RadioappWeb.LiveHelpers

  @impl true
  def mount(
        %{
          "program_id" => program_id,
          "log_id" => log_id
        },
        session,
        socket
      ) do
    tenant = Map.fetch!(session, "subdomain")
    socket =
      assign_stationdefaults(session, socket)
      |> assign(:tenant, tenant)

    current_role = socket.assigns.current_user.role

    log = Station.get_log!(log_id, tenant)
    talking_seconds = Station.talking_segments(log, tenant)
    talking = Station.formatted_length(talking_seconds)
    segments = Station.list_segments_for_log(log, tenant)
    [new_music, can_con_music, instrumental_music, hit_music] = Station.track_minutes(log, tenant)

    {:ok,
     assign(socket,
       program: Station.get_program!(program_id, tenant),
       log: log,
       talking: talking,
       segments: segments,
       new_music: new_music,
       hit_music: hit_music,
       instrumental_music: instrumental_music,
       can_con_music: can_con_music,
       current_role: current_role, 
       tenant: tenant
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, %{
         "program_id" => program_id,
         "log_id" => log_id
       }) do
    tenant = socket.assigns.tenant
    program = Station.get_program!(program_id, tenant)
    log = Station.get_log!(log_id, tenant)
    list_categories = Admin.list_categories_dropdown(tenant)

    socket
    |> assign(:page_title, "New Segment")
    |> assign(:program, program)
    |> assign(:log, log)
    |> assign(:list_categories, list_categories)
    |> assign(:segment, %Segment{})
  end

  defp apply_action(socket, :edit, %{
         "id" => id,
         "program_id" => program_id
       }) do
    tenant = socket.assigns.tenant
    program = Station.get_program!(program_id, tenant)
    list_categories = Admin.list_categories_dropdown(tenant)

    socket
    |> assign(:page_title, "Edit Segment")
    |> assign(:program, program)
    |> assign(:list_categories, list_categories)
    |> assign(:segment, Station.get_segment!(id, tenant))
  end

  defp apply_action(socket, :index, %{
    "log_id" => log_id}) do
    tenant = socket.assigns.tenant
    _log = Station.get_log!(log_id, tenant)
    #new_music_minutes = Station.new_music_minutes(log)

    socket
    |> assign(:page_title, "Listing Segments")
    |> assign(:segment, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tenant = socket.assigns.tenant
    segment = Station.get_segment!(id, tenant)
    if socket.assigns.current_user.role == :admin do
      {:ok, _} = Station.delete_segment(segment)
    end

    {:noreply, assign(socket, :segments, list_segments(tenant))}
  end

  defp list_segments(tenant) do
    Station.list_segments(tenant)
  end
end
