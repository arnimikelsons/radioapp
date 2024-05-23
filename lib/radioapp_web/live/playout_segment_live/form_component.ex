defmodule RadioappWeb.PlayoutSegmentLive.FormComponent do
  use RadioappWeb, :live_component

  alias Radioapp.Station
  # alias Radioapp.Station.PlayoutSegment

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Add segment to this show.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="segment-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :start_time}} type="time" label="Start Time" step="1" />
        <%!-- <.input field={{f, :duration}} type="text" label="Duration (e.g.: 3600, 1h30m, 24s, 30m4s)" step="1" /> --%>
        <.input field={{f, :end_time}} type="time" label="End Time" step="1" />
        <.input field={{f, :artist}} type="text" label="Artist" />
        <.input field={{f, :song_title}} type="text" label="Song Title" />
        <.input
          field={{f, :category_id}}
          type="select"
          label="Select category"
          options={@list_categories}
        />
        <.input field={{f, :catalogue_number}} type="text" label="Catalogue #" />
        <.input
          field={{f, :socan_type}}
          type="select"
          label="Select SOCAN Music Type"
          options=
          {([" ": " ", "Background": "Background", "Feature": "Feature","Theme": "Theme"])}
        />
        <.input field={{f, :can_con}} type="checkbox" label="Can Con" />
        <.input field={{f, :hit}} type="checkbox" label="Hit" />
        <.input field={{f, :instrumental}} type="checkbox" label="Instrumental" />
        <.input field={{f, :new_music}} type="checkbox" label="New Music" />
        <.input field={{f, :indigenous_artist}} type="checkbox" label="Indigenous Artist" />
        <.input field={{f, :emerging_artist}} type="checkbox" label="Emerging Artist" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Segment</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{playout_segment: playout_segment} = assigns, socket) do


    changeset = Station.change_playout_segment(playout_segment)

    {:ok,
    socket
      |> assign(assigns)
      |> assign(:changeset, changeset)}



  end

  @impl true
  def handle_event("validate", %{"playout_segment" => playout_segment_params} = params, socket) do
    changeset =
      socket.assigns.playout_segment
      |> Station.change_playout_segment(playout_segment_params)
      |> Map.put(:action, :validate)

    # changeset =
    #   case Map.get(params, "_target") do
    #     ["segment", "duration"] ->
    #       Segment.change_end_time(changeset)

    #     ["segment", "end_time"] ->
    #       Segment.change_duration(changeset)

    #     _ ->
    #       changeset
    #   end

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"playout_segment" => playout_segment_params}, socket) do
    save_playout_segment(socket, socket.assigns.action, playout_segment_params)
  end

  defp save_playout_segment(socket, :edit, playout_segment_params) do
    case Station.update_playout_segment(socket.assigns.playout_segment, playout_segment_params) do
      {:ok, _playout_segment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Segment updated successfully")
         |> push_navigate(to: socket.assigns.navigate_edit)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  # defp save_segment(socket, :new, playout_segment_params) do
  #   tenant = socket.assigns.tenant
  #   log = socket.assigns.log

  #   case Station.create_segment(log, segment_params, tenant) do
  #     {:ok, _segment} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Segment created successfully")
  #        |> push_navigate(to: socket.assigns.navigate)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Error creating segment")
  #        |> assign(changeset: changeset)}
  #   end
  # end
end
