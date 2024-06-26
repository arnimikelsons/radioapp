defmodule RadioappWeb.LinkLive.Show do
  use RadioappWeb, :live_view

  alias Radioapp.Admin
  import RadioappWeb.LiveHelpers

  @impl true
  def mount(_params, session, socket) do
    tenant = Map.fetch!(session, "subdomain")

    socket =
      assign_stationdefaults(session, socket)
      |> assign(:tenant, tenant)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    tenant = socket.assigns.tenant
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:link, Admin.get_link!(id, tenant))}
  end

  defp page_title(:show), do: "Show Link"
  defp page_title(:edit), do: "Edit Link"
end
