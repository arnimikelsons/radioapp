defmodule RadioappWeb.CategoryLive.Index do
  use RadioappWeb, :live_view

  alias Radioapp.Admin
  alias Radioapp.Admin.Category
  import RadioappWeb.LiveHelpers


  @impl true
  def mount(_params, session, socket) do
    tenant = Map.fetch!(session, "subdomain")
    socket =
      assign_stationdefaults(session, socket)
      |> assign(:tenant, tenant)
    

    {:ok, assign(socket, :categories, list_categories(tenant))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    tenant = socket.assigns.tenant
    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, Admin.get_category!(id, tenant))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Categories")
    |> assign(:category, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tenant = socket.assigns.tenant
    category = Admin.get_category!(id, tenant)
    {:ok, _} = Admin.delete_category(category)

    {:noreply, assign(socket, :categories, list_categories(tenant))}
  end

  defp list_categories(tenant) do
    Admin.list_categories(tenant)
  end
end
