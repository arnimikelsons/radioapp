defmodule RadioappWeb.LogLive.Show do
  use RadioappWeb, :live_view

  alias Radioapp.Station
  import RadioappWeb.LiveHelpers

  @impl true
  def mount(
        %{
          "id" => id,
          "program_id" => program_id
        },
        session,
        socket
      ) do
    tenant = Map.fetch!(session, "subdomain")
    socket = assign_defaults(session, socket)
    current_role = socket.assigns.current_user.role

    {:ok,
     assign(socket,
       program: Station.get_program!(program_id, tenant),
       tenant: tenant,
       log: Station.get_log!(id, tenant),
       current_role: current_role
     )}
  end

  @impl true
  def handle_params(_, _, socket) do
    tenant = socket.assigns.tenant
    log = socket.assigns.log

    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:log, log)
      |> assign(:segments, Station.list_segments_for_log(log, tenant))
    }
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tenant = socket.assigns.tenant
    segment = Station.get_segment!(id, tenant)

    if socket.assigns.current_user.role == :admin do
      {:ok, _} = Station.delete_segment(segment)
    end

    {:noreply, assign(socket, :segments, Station.list_segments_for_log(socket.assigns.log))}
  end

  defp page_title(:show), do: "Log"
  defp page_title(:edit), do: "Edit Log"
end
