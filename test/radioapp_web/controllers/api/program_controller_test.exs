defmodule RadioappWeb.Api.ProgramControllerTest do
  use RadioappWeb.ConnCase

  alias Radioapp.Factory
  alias Radioapp.Admin

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "show" do

    test "Gets the currently playing show", %{conn: conn} do
      timezone = "America/Vancouver"
      Factory.insert(:stationdefaults, [timezone: timezone, callsign: "CLDP" ], prefix: @prefix)

      now = DateTime.to_naive(Timex.now(timezone))
      time_now = DateTime.to_time(Timex.now(timezone))
      weekday = Timex.weekday(now)
      endtime = Time.add(time_now, 60, :minute)

       # Given a program
       program = Factory.insert(:program, [], prefix: @prefix)

      name = program.name
      # When we create a timeslot for right now
      Factory.insert(:timeslot, [program: program, day: weekday, runtime: 60, starttime: time_now, endtime: endtime], prefix: @prefix)

      conn = get(conn, ~p"/api/shows")
      assert %{
        "current" => [^name]
      } = json_response(conn, 200)["data"]
    end
  end

end
