defmodule RadioappWeb.PlayerLiveTest do
  use RadioappWeb.ConnCase

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  alias Radioapp.Factory

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  describe "player_live" do
    test "The Pop Up Player Button does not display inside Pop Up", %{conn: conn} do
      Factory.insert(:stationdefaults, [], prefix: @prefix)

      conn = get(conn, ~p"/player")
      assert html_response(conn, 200) =~ "<audio id=\"music\" crossorigin=\"anonymous\""
      refute html_response(conn, 200) =~ "<a href='./player'"

      {:ok, _view, _html} = live(conn)
    end

    test "Connected mount (LiveView)", %{conn: conn} do
      Factory.insert(:stationdefaults, [], prefix: @prefix)

      {:ok, _view, html} = live(conn, ~p"/player")
      assert html =~ "<audio id=\"music\" crossorigin=\"anonymous\""
    end

  end
end
