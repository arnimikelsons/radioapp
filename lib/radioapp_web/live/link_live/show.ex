defmodule RadioappWeb.LinkLive.Show do
  use RadioappWeb, :live_view

  alias Radioapp.Admin
  import RadioappWeb.LiveHelpers

  @impl true
  def mount(_params, session, socket) do

    socket =
      assign_defaults(session, socket)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:link, Admin.get_link!(id))}
  end

  defp page_title(:show), do: "Show Link"
  defp page_title(:edit), do: "Edit Link"
end
