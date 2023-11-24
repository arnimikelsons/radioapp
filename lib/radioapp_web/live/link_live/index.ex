defmodule RadioappWeb.LinkLive.Index do
  use RadioappWeb, :live_view

  alias Radioapp.Admin
  alias Radioapp.Admin.Link
  import RadioappWeb.LiveHelpers

  @impl true
  def mount(_params, session, socket) do
    tenant = Map.fetch!(session, "subdomain")

    socket =
      assign_stationdefaults(session, socket)
      |> assign(:tenant, tenant)
      |> assign(:links, list_links(tenant))
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    tenant = socket.assigns.tenant

    socket
    |> assign(:page_title, "Edit Link")
    |> assign(:link, Admin.get_link!(id, tenant))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Link")
    |> assign(:link, %Link{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Links")
    |> assign(:link, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tenant = socket.assigns.tenant
    link = Admin.get_link!(id, tenant)
    {:ok, _} = Admin.delete_link(link)

    {:noreply, assign(socket, :links, list_links(tenant))}
  end

  defp list_links(tenant) do
    Admin.list_links(tenant)
  end
end
