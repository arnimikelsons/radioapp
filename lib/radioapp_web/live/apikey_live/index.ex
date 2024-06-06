defmodule RadioappWeb.ApikeyLive.Index do
  use RadioappWeb, :live_view

  alias Radioapp.Admin
  alias Radioapp.Accounts
  import RadioappWeb.LiveHelpers


  @impl true
  def mount(_params, session, socket) do
    tenant = Map.fetch!(session, "subdomain")
    socket =
      assign_stationdefaults(session, socket)
      |> assign(:tenant, tenant)
      |> assign(:token, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New API Key")
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Create an API Key")
    |> assign(:category, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tenant = socket.assigns.tenant
    category = Admin.get_category!(id, tenant)
    {:ok, _} = Admin.delete_category(category)

    {:noreply, socket}
  end


  @impl true
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _, socket) do
    # tenant = socket.assigns.tenant
    token = Accounts.create_user_api_token(socket.assigns.current_user)
    socket = assign(socket, :token, token)


    {:noreply,
      socket
      # |> assign(:token, token)
      |> put_flash(:info, "API Key generated successfully")
      # |> push_navigate(to: ~p"/admin/apikey")
    }

  end
end
