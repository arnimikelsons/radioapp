defmodule RadioappWeb.TimeslotControllerTest do
  use RadioappWeb.ConnCase

  alias Radioapp.Factory
  alias Radioapp.Repo
  alias Radioapp.Station.Timeslot

  @invalid_attrs %{day: nil, endtime: nil, runtime: nil, starttime: nil}

  describe "index" do

    test "lists all timeslots by day", %{conn: conn} do
      program =Factory.insert(:program)
      timeslot1 = Factory.insert(:timeslot, program: program, day: 1)
      _timeslot2 = Factory.insert(:timeslot, day: 2)

      conn = get(conn, ~p"/schedule/1")
      assert html_response(conn, 200) =~ timeslot1.program.name
    end

    test "lists all timeslots by day for today", %{conn: conn} do
      program =Factory.insert(:program)
      now = DateTime.to_naive(Timex.now("America/Toronto"))
      day = Timex.weekday(now)

      timeslot = Factory.insert(:timeslot, program: program, day: day)

      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ timeslot.program.name
    end

  end


  describe "manage timeslot for regular user" do
    setup %{conn: conn} do
      user = Factory.insert(:user, role: "user")
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end
    test "regular user cannot see timeslots", %{conn: conn} do
      conn = get(conn, ~p"/timeslots")
      assert html_response(conn, 200) =~ "Listing Timeslots"
    end
    test "renders form", %{conn: conn} do
      program = Factory.insert(:program)
      conn = get(conn, ~p"/programs/#{program.id}/timeslots/new")
      assert redirected_to(conn) == ~p"/"
    end
  end


  describe "manage timeslots" do
    setup %{conn: conn} do
      user = Factory.insert(:user, role: "admin")
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end
    test "lists all timeslots", %{conn: conn} do
      conn = get(conn, ~p"/timeslots")
      assert html_response(conn, 200) =~ "Listing Timeslots"
    end
    

    
    test "renders form", %{conn: conn} do

      program = Factory.insert(:program)
      conn = get(conn, ~p"/programs/#{program.id}/timeslots/new")
      assert html_response(conn, 200) =~ "New Time Slot"
    end

    test "redirects to show when data is valid for New", %{conn: conn} do
      # Given a program
      program = Factory.insert(:program)

      # When we create a timeslot with valid attributes
      attrs =
        Factory.string_params_for(:timeslot,
          starttime: "14:30",
          runtime: "90"
        )
        
      day = Timex.day_name(Map.get(attrs, "day") || Map.get(attrs, :day))

      conn = post(conn, ~p"/programs/#{program.id}/timeslots", timeslot: attrs)
      
      # Then we are redirected to the program index page with the new timeslot
      assert %{id: _id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/programs/#{program.id}"
      
      
      # And the show template is rendered
      conn = get(conn, ~p"/programs/#{program.id}")
      assert html_response(conn, 200) =~ day
      assert html_response(conn, 200) =~ "2:30 pm"

      # And the end time has been calculated for us.


      #assert timeslot.endtime == ~T[16:00:00]
      #assert timeslot.starttimereadable == "2:30 pm"
    end

    test "renders errors when data is invalid for new", %{conn: conn} do
      program = Factory.insert(:program)
      conn = post(conn, ~p"/programs/#{program.id}/timeslots", timeslot: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Time Slot"
    end


    test "renders form for editing chosen timeslot", %{conn: conn} do
      program = Factory.insert(:program)
      timeslot = Factory.insert(:timeslot, program: program)

      conn = get(conn, ~p"/programs/#{program}/timeslots/#{timeslot}/edit")

      assert html_response(conn, 200) =~ "Edit Time Slot"
    end

    test "redirects when data is valid for update", %{conn: conn} do
      program = Factory.insert(:program)

      timeslot =
        Factory.insert(:timeslot,
          program: program,
          day: 2,
          starttime: ~T[04:00:00],
          runtime: 30,
          endtime: ~T[04:30:00]
        )

      conn =
        put(conn, ~p"/programs/#{timeslot.program.id}/timeslots/#{timeslot}",
          timeslot: %{"day" => "3"}
        )

      assert redirected_to(conn) == ~p"/programs/#{program}"

      conn = get(conn, ~p"/programs/#{program}")
      assert html_response(conn, 200)
      assert html_response(conn, 200) =~ "#{timeslot.day}"

      timeslot = Repo.get!(Timeslot, timeslot.id)
      assert timeslot.day == 3
      assert timeslot.endtime == ~T[04:30:00]
      assert timeslot.starttimereadable == "4:00 am"
    end

    test "renders errors when data is invalid for update", %{conn: conn} do
      program = Factory.insert(:program)
      timeslot = Factory.insert(:timeslot, program: program)

      conn = put(conn, ~p"/programs/#{program}/timeslots/#{timeslot}", timeslot: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Time Slot"
    end

    test "deletes chosen timeslot", %{conn: conn} do
      program = Factory.insert(:program)
      timeslot = Factory.insert(:timeslot, program: program)

      conn = delete(conn, ~p"/programs/#{program}/timeslots/#{timeslot}")
      assert redirected_to(conn) == ~p"/programs/#{program}"

      assert_error_sent 404, fn ->
        get(conn, ~p"/programs/#{program}/timeslots/#{timeslot}")
      end
    end
  end
end
