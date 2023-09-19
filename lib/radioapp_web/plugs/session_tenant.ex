defmodule RadioappWeb.Plugs.SessionTenant do

  @behaviour Plug # see this for more on behaviours: https://elixir-lang.org/getting-started/typespecs-and-behaviours.html#behaviours

  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn
    |> put_session(:subdomain, conn.assigns.current_tenant)
    |> put_session(:host, conn.assigns.host)
  end
end