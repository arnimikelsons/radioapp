defmodule RadioappWeb.SegmentLive.Index do
  use RadioappWeb, :live_view

  alias Radioapp.Station
  alias Radioapp.Station.Segment
  alias Radioapp.Admin
  import RadioappWeb.LiveHelpers
  alias Radioapp.CSV.Importer

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
    [new_music, can_con_music, instrumental_music, hit_music, indigenous_artist, emerging_artist] = Station.track_minutes(log, tenant)

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
       indigenous_artist: indigenous_artist,
       emerging_artist: emerging_artist,
       tenant: tenant
     )
      |> assign(:uploaded_files, [])
      |> assign(file_chooser_text: "No file selected")
      |> allow_upload(:csv, accept: ~w(.csv), max_entries: 3)}
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

  def handle_event("validate", _params, socket) do
    if socket.assigns.uploaded_files == [] do
      {:noreply, assign(socket, :file_choose_text, "No file selected")}
    else
      {:noreply, assign(socket, :file_choose_text, "")}
    end
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :csv, ref)}
  end

  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :csv, fn %{path: path}, _entry ->

        csv = path
          |> Path.expand(__DIR__)
          |> File.stream!()
          |> CSV.decode!()
          |> Enum.take_while(fn _x -> true end)
        # dbg(csv)

        Importer.csv_row_to_table_record(csv)

        {:ok, csv}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  defp list_segments(tenant) do
    Station.list_segments(tenant)
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
