defmodule RadioappWeb.LogLive.FormComponent do
  use RadioappWeb, :live_component

  alias Radioapp.Station

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage log records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="log-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :host_name}} type="text" label="Host's Name" />
        <.input field={{f, :date}} type="date" label="Show Date" />
        <.input field={{f, :start_time}} type="time" label="Start Time" />
        <.input field={{f, :end_time}} type="time" label="End Time" />
        <%!-- <.input field={{f, :start_datetime}} type="datetime-local" label="Start Date Time" />
        <.input field={{f, :end_datetime}} type="datetime-local" label="End Date Time" /> --%>
        <.input field={{f, :category}} type="select" label="Category" options={(["Popular Music", "Spoken Word", "Specialty Music", "Multigenre Music"])} />
        <.input field={{f, :language}} type="text" label="Show Language" />
        <.input field={{f, :notes}} type="textarea" label="notes" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Log</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{log: log} = assigns, socket) do
    changeset = Station.change_log(log)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"log" => log_params}, socket) do
    changeset =
      socket.assigns.log
      |> Station.change_log(log_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"log" => log_params}, socket) do
    save_log(socket, socket.assigns.action, log_params)
  end

  defp save_log(socket, :edit, log_params) do

    tenant = socket.assigns.tenant
    case Station.update_log(socket.assigns.log, log_params, tenant) do
      {:ok, _log} ->
        {:noreply,
         socket
         |> put_flash(:info, "Log updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_log(socket, :new, log_params) do

    tenant = socket.assigns.tenant
    program = socket.assigns.program

    case Station.create_log(program, log_params, tenant) do
      {:ok, _log} ->
        {:noreply,
         socket
         |> put_flash(:info, "Log created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
        socket
        |> put_flash(:info, "Error creating log")
        |> assign(changeset: changeset)}
    end
  end
end
