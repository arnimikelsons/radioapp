defmodule RadioappWeb.SubdomainTest do
  use RadioappWeb.ConnCase

  alias RadioappWeb.Plugs.Subdomain
  alias Plug.Conn

  test "gets the tenant from the host", %{conn: conn} do
    %Conn{assigns: assigns} = Subdomain.call(conn, :fake)
    assert assigns.current_tenant == "sample"
  end

  test "gets the tenant from some arbitrary host", %{conn: conn} do
    conn = Map.put(conn, :host, "adopt-a-family.something.example.com")
    %Conn{assigns: assigns} = Subdomain.call(conn, :host)

    assert assigns.current_tenant == "adopt-a-family"
  end
end