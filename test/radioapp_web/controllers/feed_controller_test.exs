defmodule RadioappWeb.FeedControllerTest do
  use RadioappWeb.ConnCase

  alias Radioapp.Factory
  alias Radioapp.Admin

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  describe "index" do
    test "Show the Player and Now Playing", %{conn: conn} do
      timezone = "America/Vancouver"
      Factory.insert(:stationdefaults, [timezone: timezone, callsign: "CLDP" ], prefix: @prefix)
      conn = get(conn, ~p"/feed")
      assert html_response(conn, 200) =~ "Now Playing"
      assert html_response(conn, 200) =~ "</audio>"
    end

    test "Shows the Currently Playing Show Name", %{conn: conn} do
      %{timezone: timezone} = Admin.get_stationdefaults!(@tenant)

      now = DateTime.to_naive(Timex.now(timezone))
      time_now = DateTime.to_time(Timex.now(timezone))
      weekday = Timex.weekday(now)
      endtime = Time.add(time_now, 60, :minute)
      time_now_readable = NaiveDateTime.from_erl!({{2000, 1, 1}, Time.to_erl(Time.truncate(time_now, :second))})
      |> Timex.format!("{h12}:{0m} {am}")

       # Given a program
      program = Factory.insert(:program, [], prefix: @prefix)

      name = program.name
      # When we create a timeslot for right now
      Factory.insert(:timeslot, [program: program, day: weekday, runtime: 60, starttime: time_now, endtime: endtime, starttimereadable: time_now_readable], prefix: @prefix)
      conn = get(conn, ~p"/feed")

      assert html_response(conn, 200) =~ "#{name}"
    end
  end
end
