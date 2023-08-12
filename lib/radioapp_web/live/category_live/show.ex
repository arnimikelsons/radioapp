defmodule RadioappWeb.CategoryLive.Show do
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
     |> assign(:category, Admin.get_category!(id))}
  end

  defp page_title(:show), do: "Show Category"
  defp page_title(:edit), do: "Edit Category"
end
