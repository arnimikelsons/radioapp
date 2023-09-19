defmodule RadioappWeb.Api.ProgramApiController do
  use RadioappWeb, :controller

  alias Radioapp.Station

  action_fallback RadioappWeb.FallbackController

  def index(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    programs = Station.list_programs(tenant)
    render(conn, :index, programs: programs)
  end

  def show(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    IO.inspect(tenant, label: "TENANT IN API CONTROLLER")
    render(conn, :show, tenant: tenant)
  end

end
