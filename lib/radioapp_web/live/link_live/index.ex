defmodule RadioappWeb.LinkLive.Index do
  use RadioappWeb, :live_view

  alias Radioapp.Admin
  alias Radioapp.Admin.Link
  import RadioappWeb.LiveHelpers


  @impl true
  def mount(_params, session, socket) do
    IO.inspect(session, label: "SESSION")
    IO.inspect(socket, label: "SOCKET")
    socket =
      assign_defaults(session, socket)

    {:ok, assign(socket, :links, list_links())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Link")
    |> assign(:link, Admin.get_link!(id))
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
    link = Admin.get_link!(id)
    {:ok, _} = Admin.delete_link(link)

    {:noreply, assign(socket, :links, list_links())}
  end

  defp list_links do
    Admin.list_links()
  end
end
