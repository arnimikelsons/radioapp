defmodule RadioappWeb.CategoryLive.FormComponent do
  use RadioappWeb, :live_component

  alias Radioapp.Admin

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage category records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="category-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :code}} type="text" label="CRTC Code" />
        <.input field={{f, :name}} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Category</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{category: category} = assigns, socket) do
    changeset = Admin.change_category(category)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"category" => category_params}, socket) do
    changeset =
      socket.assigns.category
      |> Admin.change_category(category_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"category" => category_params}, socket) do
    save_category(socket, socket.assigns.action, category_params)
  end

  defp save_category(socket, :edit, category_params) do
    case Admin.update_category(socket.assigns.category, category_params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Category updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_category(socket, :new, category_params) do
    case Admin.create_category(category_params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Category created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
