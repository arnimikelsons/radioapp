defmodule RadioappWeb.PlayingNow do
  use RadioappWeb, :live_view
  alias Radioapp.Station

  def render(assigns) do
    ~H"""
      <span></span>
    """
  end

  def playing_now(assigns) do
    tenant = assigns.tenant
    showName = Station.get_program_from_time(tenant)
    assigns = assign(assigns, :show_name, showName)

   ~H"""
    <span><%= @show_name %></span>
  """
  end
end
