defmodule RadioappWeb.Api.SongControllerTest do
  use RadioappWeb.ConnCase

  alias Radioapp.Accounts
  alias Radioapp.Factory
  import Radioapp.AccountsFixtures

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "song" do

    test "Inserts a new song into playout segments", %{conn: conn} do

      # First create a user to create a valid api-token
      user = user_fixture()
      token = Accounts.create_user_api_token(user)
      assert Accounts.fetch_user_by_api_token(token) == {:ok, user}

      # Create a valid stationdefaults
      timezone = "America/Vancouver"
      Factory.insert(:stationdefaults, [timezone: timezone, callsign: "CLDP" ], prefix: @prefix)

      now = DateTime.to_naive(Timex.now(timezone))
      time_now = DateTime.to_time(Timex.now(timezone))

      conn = get(conn, ~p"/api/songs/new?artist=Some Artist&title=Some Song&token=#{token}")
      assert %{
        "artist" => "Some Artist"
      } = json_response(conn, 201)["data"]


    end

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
