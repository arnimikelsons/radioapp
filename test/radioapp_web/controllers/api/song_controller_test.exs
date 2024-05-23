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

      conn = get(conn, ~p"/api/songs/new?artist=Some Artist&title=Some Song&token=#{token}")
      assert %{
        "artist" => "Some Artist"
      } = json_response(conn, 201)["data"]


    end

    test "Gets the list of playout segments", %{conn: conn} do

      # First create a user to create a valid api-token and test that it works
      user = user_fixture()
      token = Accounts.create_user_api_token(user)
      assert Accounts.fetch_user_by_api_token(token) == {:ok, user}
      # Setup a timezone and get the now time
      timezone = "America/Vancouver"
      Factory.insert(:stationdefaults, [timezone: timezone, callsign: "CLDP" ], prefix: @prefix)
      now = DateTime.to_naive(Timex.now(timezone))
      # insert a song
      expected_artist = "An artist name"
      expected_song_title = "A song title"
      conn = get(conn, ~p"/api/songs/new?artist=#{expected_artist}&title=#{expected_song_title}&token=#{token}")
      # make a request to the index
      conn = get(conn, ~p"/api/songs?token=#{token}")
      # test for the song
      assert [%{
        "artist" => artist,
        "song_title" => song_title,
        "start_time" => start_time
      }] = json_response(conn, 200)["data"]

      # Test the song has the correct values
      {:ok, formatted_current_time} = Timex.format(now, "{h24}:{m}:{s}")
      assert start_time == formatted_current_time

      assert expected_artist == artist
      assert expected_song_title == song_title
    end
  end

end
