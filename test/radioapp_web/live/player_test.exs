defmodule RadioappWeb.PlayerLiveTest do
  use RadioappWeb.ConnCase

  # import Plug.Conn
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  describe "player_live" do
    test "The Pop Up Player Button does not display inside Pop Up", %{conn: conn} do

      conn = get(conn, ~p"/player")
      assert html_response(conn, 200) =~ "<audio id=\"music\" crossorigin=\"anonymous\""
      refute html_response(conn, 200) =~ "<a href='./player'"

      {:ok, _view, _html} = live(conn)
    end

    test "Connected mount (LiveView)", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/player")
      assert html =~ "<audio id=\"music\" crossorigin=\"anonymous\""
    end

    # The following test concept doesn't work because there is no phx-click on the button#pButton
    # How else can Phoenix test for Javascript based UI interactions?

    # test "When Play is pressed, Pause appears", %{conn: conn} do
    #   {:ok, view, _html} = live(conn, "/player")

    #   assert view
    #     |> element("button#pButton")
    #     |> render_click() =~ "<svg class=\"player-pause\""

    #   # Check that it turns back to a play button when clicked again
    #   assert view
    #     |> element("button#pButton")
    #     |> render_click() =~ "<svg id=\"player-play\""

    # end
  end
end
