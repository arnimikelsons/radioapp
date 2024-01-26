defmodule RadioappWeb.FeedController do
  use RadioappWeb, :controller
  alias Radioapp.Station
  # alias RadioappWeb.ShowTimeHelper

  def index(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    show_name = Station.get_program_from_time(tenant)
    render(conn, "index.html", show_name: show_name)
  end
end
