defmodule RadioappWeb.TimezoneTest do
  use RadioappWeb.ConnCase

  # import Phoenix.ConnTest
  # import Phoenix.LiveViewTest

  # alias Radioapp.Factory

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  # describe "LiveViews" do
  #   test "The currently playing program in the timezone of the station is displayed", %{conn: conn} do
  #     timezone = "Canada/Newfoundland"

  #     now = DateTime.to_naive(Timex.now(timezone))
  #     time_now = DateTime.to_time(Timex.now(timezone))
  #     half_hour_ago = Time.add(time_now, -30, :minute)
  #     weekday = Timex.weekday(now)

  #     Factory.insert(:stationdefaults, [callsign: "CKTT", timezone: timezone], prefix: @prefix)
  #     program = Factory.insert(:program, [], prefix: @prefix)

  #     timeslot = Factory.insert(:timeslot, [day: weekday, starttime: half_hour_ago, runtime: 120, program: program], prefix: @prefix)

  #     {:ok, _view, html} = live(conn, ~p"/player")
  #     assert html =~ "<audio id=\"music\" crossorigin=\"anonymous\""
  #     # assert html =~ timeslot.program.name
  #     conn = get(conn, ~p"/player")
  #     html = html_response(conn, 200)

  #     conn = get(conn, ~p"/player")
  #     assert html_response(conn, 200) =~ timeslot.program.name

  #     conn = get(conn, ~p"/")
  #     assert html_response(conn, 200) =~ timeslot.program.name
  #   end
  # end
end
