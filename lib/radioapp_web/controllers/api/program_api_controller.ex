defmodule RadioappWeb.Api.ProgramApiController do
  use RadioappWeb, :controller

  alias Radioapp.Station

  action_fallback RadioappWeb.FallbackController

  def index(conn, _params) do
    programs = Station.list_programs()
    render(conn, :index, programs: programs)
  end

  def show(conn, _params) do
    render(conn, :show, program: "test")
  end

end
