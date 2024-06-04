defmodule RadioappWeb.DangerController do
  use RadioappWeb, :controller

  alias Radioapp.Station
  import Ecto.Query, warn: false

  def deleteplayout_segments(conn, _params) do
    current_user = conn.assigns.current_user
    render(conn, "deleteplayout_segments.html", current_user: current_user)
  end

  def deleteallplayout_segments(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    Station.delete_all_playout_segments(tenant)

    conn
    |> put_flash(:info, "All playout segments deleted successfully.")
    |> redirect(to: ~p"/playout_segments")
  end

end
