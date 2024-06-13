defmodule RadioappWeb.PlayerLive do
  use RadioappWeb, :live_player_view
  alias Radioapp.Station
  alias Radioapp.Admin

  def mount(_params, session, socket) do
    tenant = Map.fetch!(session, "subdomain")
    socket = assign(socket, tenant: tenant)

    if connected?(socket) do
      Process.send_after(self(), :tick, 60 * 1000) # In 1 minute
    end

    socket =
      socket
      |> assign(
        volume: 1.0,
        saved: 1.0,
        playing: false
      )

    stationdefaults = Admin.get_stationdefaults!(tenant)
    socket = assign(socket, stationdefaults: stationdefaults)

    socket = assign_show(socket)
    if socket.assigns.live_action == :pop do
      socket = assign(socket, page_title: "Pop-Up Player")
      # socket = assign(socket, layout: {RadioappWeb.Layouts, "pop"})
      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def handle_event("play_pause", _, socket) do
    %{playing: playing} = socket.assigns

    cond do
      playing ->
        {:noreply, assign(socket, playing: false)}

      !playing ->
        {:noreply, assign(socket, playing: true)}

      true ->
        {:noreply, socket}
    end
  end

  def handle_info(:tick, socket) do
    socket = assign_show(socket)
    {:noreply, socket}
  end

  def assign_show(socket) do
    tenant = socket.assigns.tenant
    showName = Station.get_program_from_time(tenant)
    startTime = Station.get_program_now_start_time(tenant)
    assign(socket,
      show_name: showName,
      show_start: startTime
    )
  end

  def render(assigns) do
    ~H"""
      <div class="third-row row">
        <div>
          <h3>Now Playing</h3>
          <h2 class="text-xl font-medium text-black pop-up-title"><%= @show_name %></h2>
          <h3 id="time-format"><%= @show_start %></h3>
        </div>
      </div>
    """
  end
end
