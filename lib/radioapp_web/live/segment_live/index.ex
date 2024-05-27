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

    current_user = socket.assigns.current_user

    user_role =
      if Map.get(current_user.roles, tenant) == nil do
        Map.get(current_user.roles, "admin")
      else
        Map.get(current_user.roles, tenant)
      end

    log = Station.get_log!(log_id, tenant)
    talking_seconds = Station.talking_segments(log, tenant)
    talking = Station.formatted_length(talking_seconds)
    segments = Station.list_segments_for_log(log, tenant)
    [new_music, can_con_music, instrumental_music, hit_music, indigenous_artist, emerging_artist] = Station.track_minutes(log, tenant)

    %{csv_permission: permission} = Admin.get_stationdefaults!(tenant)
    csv_permission =
      case permission do
        "admin" ->
          if user_role == "admin" or user_role == "super_admin" do
            true
          else
            false
          end
        "user" ->
          true
        "none" ->
          false
      end

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
       current_role: user_role,
       indigenous_artist: indigenous_artist,
       emerging_artist: emerging_artist,
       tenant: tenant,
       csv_permission: csv_permission
     )
      |> assign(:uploaded_files, [])
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

  defp apply_action(socket, :upload_instructions, _params) do
    socket
    |> assign(:page_title, "Upload Instructions")
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tenant = socket.assigns.tenant
    segment = Station.get_segment!(id, tenant)
    if socket.assigns.current_role == :admin do
      {:ok, _} = Station.delete_segment(segment)
    end

    {:noreply, assign(socket, :segments, list_segments(tenant))}
  end

  def handle_event("validate", _params, socket) do
      {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :csv, ref)}
  end

  def handle_event("upload", _params, socket) do
    tenant = socket.assigns.tenant
    log = socket.assigns.log
    [csv] = consume_uploaded_entries(socket, :csv, fn %{path: path}, _entry ->
      csv = path
        |> Path.expand(__DIR__)
        |> File.stream!()
        |> CSV.decode!()
        |> Enum.take_while(fn _x -> true end)
      {:ok, csv}
    end)
    # uploaded_files = csv
    case Importer.csv_row_to_table_record(csv, log, tenant) do
      {:ok, _} ->
        # segments = Station.list_segments_for_log(log, tenant)
        {:noreply,
          socket
            # See if there's a way of not doing a redirect here, but Drag and drop would still work
            |> redirect(to: "/programs/#{socket.assigns.program.id}/logs/#{log.id}/segments")
            |> put_flash(:info, "CSV Uploaded successfully")
            # |> assign(:segments, Station.list_segments_for_log(log, tenant))
            # |> update(:uploaded_files, &(&1 ++ [uploaded_files]))
          }

      {:error, reason} ->
        {:noreply,
          socket
            |> redirect(to: "/programs/#{socket.assigns.program.id}/logs/#{log.id}/segments")
            |> put_flash(:error, reason)}
    end
  end

  defp list_segments(tenant) do
    Station.list_segments(tenant)
  end

  defp error_to_string(:too_large), do: "The file is too large."
  defp error_to_string(:too_many_files), do: "You have selected too many files."
  defp error_to_string(:not_accepted), do: "You have selected an incorrect file type."
end
