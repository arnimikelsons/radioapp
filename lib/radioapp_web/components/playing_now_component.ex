defmodule RadioappWeb.PlayingNowComponent do
  # use Phoenix.LiveComponent
  use RadioappWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end
  def render(assigns) do
    ~H"""
    <span><%= @content %></span>
    """
  end

end
