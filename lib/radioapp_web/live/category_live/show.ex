defmodule RadioappWeb.CategoryLive.Show do
  use RadioappWeb, :live_view

  alias Radioapp.Admin
  import RadioappWeb.LiveHelpers

  @impl true
  def mount(_params, session, socket) do
    tenant = Map.fetch!(session, "subdomain")

    socket =
      assign_defaults(session, socket)
      |> assign(:tenant, tenant)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    tenant = socket.assigns.tenant
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:category, Admin.get_category!(id, tenant))}
  end

  defp page_title(:show), do: "Show Category"
  defp page_title(:edit), do: "Edit Category"
end
