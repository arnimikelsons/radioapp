defmodule RadioappWeb.LinkLive.FormComponent do
  use RadioappWeb, :live_component

  alias Radioapp.Admin

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage link records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="link-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :type}} type="text" label="Link Type" />
        <.input field={{f, :icon}} type="text" label="Icon" placeholder="Put in Font Awesome 6 snippet" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Link</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{link: link} = assigns, socket) do
    changeset = Admin.change_link(link)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"link" => link_params}, socket) do
    changeset =
      socket.assigns.link
      |> Admin.change_link(link_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"link" => link_params}, socket) do
    save_link(socket, socket.assigns.action, link_params)
  end

  defp save_link(socket, :edit, link_params) do
    case Admin.update_link(socket.assigns.link, link_params) do
      {:ok, _link} ->
        {:noreply,
         socket
         |> put_flash(:info, "Link updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_link(socket, :new, link_params) do
    IO.inspect(socket, label: "SOCKET")
    tenant = socket.assigns.tenant
    case Admin.create_link(link_params, tenant) do
      {:ok, _link} ->
        {:noreply,
         socket
         |> put_flash(:info, "Link created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
