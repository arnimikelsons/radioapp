defmodule RadioappWeb.PlayingNowComponent do
  # use Phoenix.LiveComponent
  use RadioappWeb, :live_component

  alias Radioapp.Station

  def mount(socket) do

    {:ok, socket}
  end

  def update(assigns, socket) do

    tenant = assigns.tenant
    # IO.inspect(tenant, label: "TENANT")
    socket = assign(socket, tenant: tenant)
    socket = assign_show(socket)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <span><%= @show_name %></span>
    """
  end

  defp assign_show(socket) do
    # IO.inspect(socket.assigns, label: "SOCKET.ASSIGNS")
    tenant = socket.assigns.tenant
    now = DateTime.to_naive(Timex.now("America/Toronto"))
    time_now = DateTime.to_time(Timex.now("America/Toronto"))
    weekday = Timex.weekday(now)

    showName = Station.get_program_from_time(weekday, time_now, tenant)
    startTime = Station.get_program_now_start_time(weekday, time_now, tenant)

    # IO.inspect(showName, label: "SHOWNAME IN PLAYING_NOW_COMPONENT")
    showName =
    if showName == [] do
      "No Show Available"
    else
      showName
    end

    assign(socket,
      show_name: showName,
      show_start: startTime
    )
  end

end
