defmodule RadioappWeb.PlayingNowComponent do
  # use Phoenix.LiveComponent
  use RadioappWeb, :live_component

  alias Radioapp.Station

  def mount(socket) do

    {:ok, socket}
  end

  def update(assigns, socket) do
    tenant = assigns.tenant
    socket = assign(socket, tenant: tenant)
    socket = assign_show(socket)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <span id="playing-now-component"><%= @show_name %></span>
    """
  end

  defp assign_show(socket) do
    tenant = socket.assigns.tenant
    showName = Station.get_program_from_time(tenant)
    startTime = Station.get_program_now_start_time(tenant)
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
