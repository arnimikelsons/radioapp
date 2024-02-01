defmodule RadioappWeb.PageControllerTest do
  use RadioappWeb.ConnCase

  alias Radioapp.Factory

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  test "GET /", %{conn: conn} do
    timezone = "America/Vancouver"
    Factory.insert(:stationdefaults, [timezone: timezone, callsign: "CLDP" ], prefix: @prefix)

    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Community Radio Software"
  end
end
