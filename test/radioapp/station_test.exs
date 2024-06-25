defmodule Radioapp.StationTest do
  use Radioapp.DataCase
  alias Radioapp.Factory

  alias Radioapp.Station
  alias Radioapp.Station.{Program, Timeslot, Log, Segment, Image, PlayoutSegment}
  alias Radioapp.Admin

  @tenant "sample"

  @prefix Triplex.to_prefix(@tenant)

  describe "programs" do
    @valid_attrs %{
      description: "some description",
      genre: "some genre",
      name: "some name",
      short_description: "some short description"
    }

    @update_attrs %{
      description: "some updated description",
      genre: "some updated genre",
      name: "some updated name",
      short_description: "some updated short description"
    }

    @invalid_attrs %{
      description: nil,
      genre: nil,
      name: nil
    }



    test "list_programs/0 returns all programs" do
      program = Factory.insert(:program, [], prefix: @prefix)
      assert Station.list_programs(@tenant) == [program]
    end
    test "list_programs/0 with hide flag returns no programs" do
      _program = Factory.insert(:program, [hide: true], prefix: @prefix)
      assert Station.list_programs(@tenant) == []
    end

    test "list_all_programs/0 with hide flag returns all programs" do
      program = Factory.insert(:program, [hide: true], prefix: @prefix)
      assert Station.list_all_programs(@tenant) == [program]
    end

    test "get_program!/1 returns the program with given id" do
      program = Factory.insert(:program, [], prefix: @prefix)
      assert Station.get_program!(program.id, @tenant) == program
    end


    # add test for get_program_from_time(weekday, time_now)

    # add test for get_program_now_start_time(weekday, time_now)

    test "create_program/1 with valid data creates a program" do

      assert {:ok, %Program{} = program} = Station.create_program(@valid_attrs, @tenant)
      assert program.description == "some description"
      assert program.genre == "some genre"
      assert program.name == "some name"
      assert program.short_description == "some short description"
    end

    test "create_program/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Station.create_program(@invalid_attrs, @tenant)
    end

    test "update_program/2 with valid data updates the program" do
      program = Factory.insert(:program, [], prefix: @prefix)

      assert {:ok, %Program{} = program} = Station.update_program(program, @update_attrs)
      assert program.description == "some updated description"
      assert program.genre == "some updated genre"
      assert program.name == "some updated name"
      assert program.short_description == "some updated short description"
    end

    test "update_program/2 with invalid data returns error changeset" do
      program = Factory.insert(:program, [], prefix: @prefix)
      assert {:error, %Ecto.Changeset{}} = Station.update_program(program, @invalid_attrs)
      assert program == Station.get_program!(program.id, @tenant)
    end

    test "delete_program/1 deletes the program" do
      program = Factory.insert(:program, [], prefix: @prefix)
      assert {:ok, %Program{}} = Station.delete_program(program)
      assert_raise Ecto.NoResultsError, fn -> Station.get_program!(program.id, @tenant) end
    end

    test "change_program/1 returns a program changeset" do
      program = Factory.insert(:program, [], prefix: @prefix)
      assert %Ecto.Changeset{} = Station.change_program(program)
    end
  end

  describe "timeslots" do

    @update_attrs %{
      day: 43,
      endtime: ~T[15:01:01],
      runtime: 43,
      starttime:
      ~T[15:01:01]
    }

    @invalid_attrs %{
      day: nil,
      endtime: nil,
      runtime: nil,
      starttime: nil
    }


    test "list_timeslots/0 returns all timeslots" do
      program = Factory.insert(:program, [], prefix: @prefix)
      timeslot = Factory.insert(:timeslot, [program: program], prefix: @prefix)

      expected = [timeslot.id]
      assert expected == Enum.map(Station.list_timeslots(@tenant), fn t -> t.id end)
    end

    test "list_timeslots_for_program/0 returns all timeslots" do
      program1 = Factory.insert(:program, [], prefix: @prefix)
      program2 = Factory.insert(:program, [], prefix: @prefix)

      timeslot1 = Factory.insert(:timeslot, [day: 1, program: program1], prefix: @prefix)
      _timeslot2 = Factory.insert(:timeslot, [day: 2, program: program2], prefix: @prefix)

      expected = [timeslot1.id]
      assert expected == Enum.map(Station.list_timeslots_for_program(program1, @tenant), fn t -> t.id end)
      refute expected == Enum.map(Station.list_timeslots_for_program(program2, @tenant), fn t -> t.id end)
    end

    test "list_timeslots_by_day/0 returns all timeslots" do
      program1 = Factory.insert(:program, [], prefix: @prefix)
      program2 = Factory.insert(:program, [], prefix: @prefix)

      timeslot1 = Factory.insert(:timeslot, [day: 1, program: program1], prefix: @prefix)
      _timeslot2 = Factory.insert(:timeslot, [day: 2, program: program2], prefix: @prefix)

      expected = [timeslot1.id]
      assert expected == Enum.map(Station.list_timeslots_by_day(1, @tenant), fn t -> t.id end)
      refute expected == Enum.map(Station.list_timeslots_by_day(2, @tenant), fn t -> t.id end)
    end

    test "get_timeslot!/1 returns the timeslot with given id" do
      program = Factory.insert(:program, [], prefix: @prefix)
      timeslot = Factory.insert(:timeslot, [program: program], prefix: @prefix)
      get_timeslot = Station.get_timeslot!(timeslot.id, @tenant)
      assert get_timeslot.id == timeslot.id
    end

    test "create_timeslot/1 with valid data creates a timeslot" do
      program = Factory.insert(:program, [], prefix: @prefix)
      valid_attrs = %{
        day: 2,
        runtime: 42,
        starttime: ~T[14:00:00],
        program: program
      }

      assert {:ok, %Timeslot{} = timeslot} = Station.create_timeslot(program, valid_attrs, @tenant)
      assert timeslot.day == 2
      assert timeslot.runtime == 42
      assert timeslot.starttime == ~T[14:00:00]
      assert timeslot.endtime == ~T[14:42:00]
      assert timeslot.program_id == program.id
    end

    test "create_timeslot/1 with invalid data returns error changeset" do
      program = Factory.insert(:program, [], prefix: @prefix)
      assert {:error, %Ecto.Changeset{}} = Station.create_timeslot(program, @invalid_attrs)
    end

    test "update_timeslot/2 with valid data updates the timeslot" do
      program = Factory.insert(:program, [], prefix: @prefix)
      timeslot = Factory.insert(:timeslot,[program: program], prefix: @prefix)

      assert {:ok, %Timeslot{} = timeslot} = Station.update_timeslot(timeslot, @update_attrs)

      assert timeslot.day == 43
      assert timeslot.runtime == 43
      assert timeslot.starttime == ~T[15:01:01]
      assert timeslot.endtime == ~T[15:44:01]
      assert timeslot.program == program
    end

    test "update_timeslot/2 with invalid data returns error changeset" do
      program = Factory.insert(:program, [], prefix: @prefix)
      timeslot = Factory.insert(:timeslot, [program: program], prefix: @prefix)
      assert {:error, %Ecto.Changeset{}} = Station.update_timeslot(timeslot, @invalid_attrs)
      get_timeslot = Station.get_timeslot!(timeslot.id, @tenant)
      assert get_timeslot.id == timeslot.id
    end

    test "delete_timeslot/1 deletes the timeslot" do
      program = Factory.insert(:program, [], prefix: @prefix)
      timeslot = Factory.insert(:timeslot, [program: program], prefix: @prefix)

      timeslot =
        timeslot
        |> Map.merge(%{
          program: program
        })

      assert {:ok, %Timeslot{}} = Station.delete_timeslot(timeslot)
      assert Station.get_program!(program.id, @tenant) == program
      assert_raise Ecto.NoResultsError, fn -> Station.get_timeslot!(timeslot.id, @tenant) end
    end

    test "change_timeslot/1 returns a timeslot changeset" do
      program = Factory.insert(:program, [], prefix: @prefix)
      timeslot = Factory.insert(:timeslot, [program: program], prefix: @prefix)
      assert %Ecto.Changeset{} = Station.change_timeslot(timeslot)
    end
  end

  describe "logs" do
    @valid_attrs %{
      host_name: "some host name",
      notes: "some notes",
      category: "Popular Music",
      date: "2023-02-18",
      start_time: "01:11:00",
      end_time: "01:13:00",
      language: "English"
      }
      @update_attrs %{  host_name: "some updated host name",
      notes: "some updated notes",
      category: "Spoken Word",
      date: ~D[2023-03-18],
      start_time: ~T[02:11:00Z],
      end_time: ~T[02:13:00Z],
      language: "French"
      }
    @invalid_attrs %{
      notes: nil,
      category: "Spoken Word",
      date: nil,
      start_time: nil,
      end_time: nil,
      host_name: nil,
      language: nil
    }

    test "list_logs/0 returns all logs" do
      program = Factory.insert(:program, [], prefix: @prefix)
      log = Factory.insert(:log, [program: program], prefix: @prefix)

      expected = [log.id]
      assert expected == Enum.map(Station.list_logs(@tenant), fn s -> s.id end)
    end

    test "list_logs_for_timeslot/0 returns all logs" do
      program1 = Factory.insert(:program, [], prefix: @prefix)
      program2 = Factory.insert(:program, [], prefix: @prefix)

      log1 = Factory.insert(:log, [program: program1], prefix: @prefix)
      _log2 = Factory.insert(:log, [program: program2], prefix: @prefix)

      expected = [log1.id]
      assert expected == Enum.map(Station.list_logs_for_program(program1, @tenant), fn s -> s.id end)
      refute expected == Enum.map(Station.list_logs_for_program(program2, @tenant), fn s -> s.id end)
    end

    test "get_log!/1 returns the log with given id" do
      log = Factory.insert(:log, [], prefix: @prefix)
      get_log = Station.get_log!(log.id, @tenant)

      assert get_log.id == log.id
    end

    test "create_log/1 with valid data creates a log" do
      program = Factory.insert(:program, [], prefix: @prefix)

      valid_attrs = for {k, v} <- @valid_attrs,
               do: {to_string(k), v}, into: %{}

      assert {:ok, %Log{} = log} = Station.create_log(program, valid_attrs, @tenant)
      assert log.notes == "some notes"
      assert log.category == "Popular Music"
      assert log.date == ~D[2023-02-18]
      assert log.start_time == ~T[01:11:00Z]
      assert log.end_time == ~T[01:13:00Z]
      assert log.language == "English"
    end

    test "create_log/1 with invalid data returns error changeset" do
      program = Factory.insert(:program, [], prefix: @prefix)

      invalid_attrs = for {k, v} <- @invalid_attrs,
               do: {to_string(k), v}, into: %{}

      assert {:error, %Ecto.Changeset{}} = Station.create_log(program, invalid_attrs, @tenant)
    end

    test "update_log/2 with valid data updates the log" do
      log = Factory.insert(:log, [], prefix: @prefix)

      assert {:ok, %Log{} = log} = Station.update_log(log, @update_attrs)

      assert log.notes == "some updated notes"
      assert log.category == "Spoken Word"
      assert log.date == ~D[2023-03-18]
      assert log.start_time == ~T[02:11:00Z]
      assert log.end_time == ~T[02:13:00Z]
      assert log.language == "French"
    end

    test "update_log/2 with invalid data returns error changeset" do
      log = Factory.insert(:log, [], prefix: @prefix)
      assert {:error, %Ecto.Changeset{}} = Station.update_log(log, @invalid_attrs)
      get_log = Station.get_log!(log.id, @tenant)

      assert get_log.id == log.id
    end

    test "delete_log/1 deletes the log" do
    log = Factory.insert(:log, [], prefix: @prefix)
      assert {:ok, %Log{}} = Station.delete_log(log)
      assert_raise Ecto.NoResultsError, fn -> Station.get_log!(log.id, @tenant) end
    end

    test "change_log/1 returns a log changeset" do
      log = Factory.insert(:log, [], prefix: @prefix)
      assert %Ecto.Changeset{} = Station.change_log(log)
    end
  end

  test "#talking_segments_minutes" do
    # Given a log we're interested in
    log = Factory.insert(:log, [], prefix: @prefix)

    # And it has a number of segments
    category = Factory.insert(:category, [code: "11"], prefix: @prefix)
    Factory.insert(:segment,
      [log: log,
      category: category,
      start_time: ~T[02:13:25Z],
      end_time: ~T[02:15:40Z]],
      prefix: @prefix
    )

    Factory.insert(:segment,
      [log: log,
      category: category,
      start_time: ~T[14:12:00Z],
      end_time: ~T[15:15:00Z]],
      prefix: @prefix
    )

    other_category = Factory.insert(:category, [code: "21"], prefix: @prefix)
    Factory.insert(:segment,
      [log: log,
      category: other_category,
      new_music: true,
      start_time: ~T[14:12:00Z],
      end_time: ~T[15:15:00Z]],
      prefix: @prefix
    )

    # And another log we're not interested in
    other_log = Factory.insert(:log, [], prefix: @prefix)

    # And it also has a number of segments
    Factory.insert(:segment, [log: other_log, category: category], prefix: @prefix)
    Factory.insert(:segment, [log: other_log, category: other_category], prefix: @prefix)

    # When we ask for the music minutes for the log we're interested in
    # Then we see the sum of the duration of those segments
    # 65 minutes.
    assert Station.talking_segments(log, @tenant) == 3915
  end

  test "tracking minutes of segments" do
  end

  test "log contains the start_datetime utc and end_datetime utc fields with correct values" do
    # create a new log
    program = Factory.insert(:program, [], prefix: @prefix)

    valid_attrs = for {k, v} <- @valid_attrs,
              do: {to_string(k), v}, into: %{}

    assert {:ok, %Log{} = log} = Station.create_log(program, valid_attrs, @tenant)

    assert log.date == ~D[2023-02-18]
    assert log.start_time == ~T[01:11:00Z]
    assert log.end_time == ~T[01:13:00Z]
    # ensure that the value in the utc field corresponds to the values in start time, end time and date
    # timezone in stationdefaults should be Eastern
    assert Admin.get_timezone!(@tenant) == %{timezone: "Canada/Eastern"}
    assert log.start_datetime == ~U[2023-02-18 06:11:00Z]

  end

  test "update log with new date and start time modifies the utc fields start_datetime and end_datetime" do
    #Insert a stationdefaults with Atlantic timezone
    stationdefaults = Factory.insert(:stationdefaults, [timezone: "Canada/Atlantic"], prefix: @prefix)
    # create a new log
    log = Factory.insert(:log, [], prefix: @prefix)
    # modify the log using update_log with new date and start time
    assert {:ok, %Log{} = log} = Station.update_log(log, @update_attrs)
    # check the values in the utc fields match the update_attrs naive date and start time
    assert log.date == ~D[2023-03-18]
    assert log.start_time == ~T[02:11:00Z]
    assert log.end_time == ~T[02:13:00Z]
    # assert that stationdefaults is in Eastern time zone
    assert Admin.get_timezone!(@tenant) == %{timezone: "Canada/Atlantic"}
    # read the returned log and ensure utc fields have corresponding new values
    assert log.start_datetime == ~U[2023-03-18 08:11:00Z]
  end

  describe "segments" do

    @valid_attrs %{
      artist: "some artist",
      can_con: true,
      catalogue_number: "12345",
      category_id: 1,
      start_time: ~T[02:11:00Z],
      end_time: ~T[02:13:00Z],
      hit: true,
      instrumental: false,
      new_music: true,
      socan_type: "some socan type",
      song_title: "some song title",
      indigenous_artist: true,
      emerging_artist: false
    }
    @update_attrs %{
      artist: "some updateed artist",
      can_con: false,
      catalogue_number: "54321",
      category_id: 2,
      start_time: ~T[03:11:00Z],
      end_time: ~T[03:13:00Z],
      hit: false,
      instrumental: true,
      new_music: false,
      socan_type: "some updated socan type",
      song_title: "some updated song title",
      indigenous_artist: false,
      emerging_artist: true
    }
    @invalid_attrs %{
      artist: nil,
      can_con: false,
      catalogue_number: nil,
      start_time: nil,
      end_time: nil,
      hit: false,
      instrumental: false,
      new_music: false,
      socan_type: nil,
      song_title: nil,
      indigenous_artist: false,
      emerging_artist: false
    }

    test "list_segments/0 returns all segments" do
      segment = Factory.insert(:segment, [], prefix: @prefix)

      expected = [segment.id]
      assert expected == Enum.map(Station.list_segments(@tenant), fn s -> s.id end)
    end

    test "list_segments_for_log/0 returns all segments for a given log" do
      log1 = Factory.insert(:log, [], prefix: @prefix)
      log2 = Factory.insert(:log, [], prefix: @prefix)

      segment1 = Factory.insert(:segment, [log: log1], prefix: @prefix)
      _segment2 = Factory.insert(:segment, [log: log2], prefix: @prefix)

      expected = [segment1.id]
      assert expected == Enum.map(Station.list_segments_for_log(log1, @tenant), fn s -> s.id end)
      refute expected == Enum.map(Station.list_segments_for_log(log2, @tenant), fn s -> s.id end)
    end

    test "get_segment!/1 returns the segment with given id" do
      segment = Factory.insert(:segment, [], prefix: @prefix)

      get_segment = Station.get_segment!(segment.id, @tenant)
      assert get_segment.id == segment.id
    end

    test "create_segment/1 with valid data creates a segment" do
      program = Factory.insert(:program, [], prefix: @prefix)
      log = Factory.insert(:log, [program: program], prefix: @prefix)
      _valid_category = Factory.insert(:category, [id: 1], prefix: @prefix)
      assert {:ok, %Segment{} = segment} = Station.create_segment(log, @valid_attrs, @tenant)
      assert segment.can_con == true
      assert segment.catalogue_number == "12345"
      assert segment.start_time == ~T[02:11:00Z]
      assert segment.end_time == ~T[02:13:00Z]
      assert segment.hit == true
      assert segment.instrumental == false
      assert segment.new_music == true
      assert segment.socan_type == "some socan type"
      assert segment.song_title == "some song title"
      assert segment.indigenous_artist == true
      assert segment.emerging_artist == false
    end

    test "create_segment/1 with invalid data returns error changeset" do
      program = Factory.insert(:program, [], prefix: @prefix)
      log = Factory.insert(:log, [program: program], prefix: @prefix)
      assert {:error, %Ecto.Changeset{}} = Station.create_segment(log, @invalid_attrs, @tenant)
    end

    test "update_segment/2 with valid data updates the segment" do
      segment = Factory.insert(:segment, [], prefix: @prefix)
      _update_category = Factory.insert(:category, [id: 2], prefix: @prefix)
      assert {:ok, %Segment{} = segment} = Station.update_segment(segment, @update_attrs)
      assert segment.can_con == false
      assert segment.catalogue_number == "54321"
      assert segment.start_time == ~T[03:11:00Z]
      assert segment.end_time == ~T[03:13:00Z]
      assert segment.hit == false
      assert segment.instrumental == true
      assert segment.new_music == false
      assert segment.socan_type == "some updated socan type"
      assert segment.song_title == "some updated song title"
      assert segment.indigenous_artist == false
      assert segment.emerging_artist == true
    end

    test "update_segment/2 with invalid data returns error changeset" do
      segment = Factory.insert(:segment, [], prefix: @prefix)
      assert {:error, %Ecto.Changeset{}} = Station.update_segment(segment, @invalid_attrs)

      get_segment = Station.get_segment!(segment.id, @tenant)
      assert get_segment.id == segment.id
    end

    test "delete_segment/1 deletes the segment" do
      segment = Factory.insert(:segment, [], prefix: @prefix)
      assert {:ok, %Segment{}} = Station.delete_segment(segment)
      assert_raise Ecto.NoResultsError, fn -> Station.get_segment!(segment.id, @tenant) end
    end

    test "change_segment/1 returns a segment changeset" do
      segment = Factory.insert(:segment, [], prefix: @prefix)
      assert %Ecto.Changeset{} = Station.change_segment(segment)
    end
  end

  describe "playout_segments" do

    @valid_attrs %{
      artist: "some artist",
      can_con: true,
      catalogue_number: "12345",
      category_id: 1,
      start_time: ~T[02:11:00Z],
      end_time: ~T[02:13:00Z],
      hit: true,
      instrumental: false,
      new_music: true,
      socan_type: "some socan type",
      song_title: "some song title",
      indigenous_artist: true,
      emerging_artist: false
    }
    @update_attrs %{
      artist: "some updated artist",
      can_con: false,
      catalogue_number: "54321",
      category_id: 2,
      start_time: ~T[03:11:00Z],
      end_time: ~T[03:13:00Z],
      hit: false,
      instrumental: true,
      new_music: false,
      socan_type: "some updated socan type",
      song_title: "some updated song title",
      indigenous_artist: false,
      emerging_artist: true
    }
    @invalid_attrs %{
      artist: nil,
      can_con: false,
      catalogue_number: nil,
      start_time: nil,
      end_time: nil,
      hit: false,
      instrumental: false,
      new_music: false,
      socan_type: nil,
      song_title: nil,
      indigenous_artist: false,
      emerging_artist: false
    }

    test "list_playout_segments/0 returns all playout_segments" do
      playout_segment = Factory.insert(:playout_segment, [], prefix: @prefix)
      expected = [playout_segment.id]
      assert expected == Enum.map(Station.list_playout_segments(@tenant), fn s -> s.id end)
    end

    test "get_playout_segment!/1 returns the segment with given id" do
      playout_segment = Factory.insert(:playout_segment, [], prefix: @prefix)
      get_playout_segment = Station.get_playout_segment!(playout_segment.id, @tenant)
      assert get_playout_segment.id == playout_segment.id
    end

    test "create_playout_segment/1 with valid data creates a segment" do
      _valid_category = Factory.insert(:category, [id: 1], prefix: @prefix)
      assert {:ok, %PlayoutSegment{} = playout_segment} = Station.create_playout_segment(@valid_attrs, @tenant)
      assert playout_segment.can_con == true
      assert playout_segment.catalogue_number == "12345"
      assert playout_segment.start_time == ~T[02:11:00Z]
      assert playout_segment.end_time == ~T[02:13:00Z]
      assert playout_segment.hit == true
      assert playout_segment.instrumental == false
      assert playout_segment.new_music == true
      assert playout_segment.socan_type == "some socan type"
      assert playout_segment.song_title == "some song title"
      assert playout_segment.indigenous_artist == true
      assert playout_segment.emerging_artist == false
    end

    test "create_playout_segment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Station.create_playout_segment(@invalid_attrs, @tenant)
    end

    test "update_playout_segment/2 with valid data updates the segment" do
      playout_segment = Factory.insert(:playout_segment, [], prefix: @prefix)
      _update_category = Factory.insert(:category, [id: 2], prefix: @prefix)
      assert {:ok, %PlayoutSegment{} = playout_segment} = Station.update_playout_segment(playout_segment, @update_attrs)
      assert playout_segment.can_con == false
      assert playout_segment.catalogue_number == "54321"
      assert playout_segment.start_time == ~T[03:11:00Z]
      assert playout_segment.end_time == ~T[03:13:00Z]
      assert playout_segment.hit == false
      assert playout_segment.instrumental == true
      assert playout_segment.new_music == false
      assert playout_segment.socan_type == "some updated socan type"
      assert playout_segment.song_title == "some updated song title"
      assert playout_segment.indigenous_artist == false
      assert playout_segment.emerging_artist == true
    end

    test "update_playout_segment/2 with invalid data returns error changeset" do
      playout_segment = Factory.insert(:playout_segment, [], prefix: @prefix)
      assert {:error, %Ecto.Changeset{}} = Station.update_playout_segment(playout_segment, @invalid_attrs)
      get_playout_segment = Station.get_playout_segment!(playout_segment.id, @tenant)
      assert get_playout_segment.id == playout_segment.id
    end

    test "delete_playout_segment/1 deletes the playout_segment" do

      playout_segment = Factory.insert(:playout_segment, [], prefix: @prefix)
      assert {:ok, %PlayoutSegment{}} = Station.delete_playout_segment(playout_segment)
      assert_raise Ecto.NoResultsError, fn -> Station.get_playout_segment!(playout_segment.id, @tenant) end

    end

    test "change_playout_segment/1 returns a playout_segment changeset" do
      playout_segment = Factory.insert(:playout_segment, [], prefix: @prefix)
      assert %Ecto.Changeset{} = Station.change_playout_segment(playout_segment)
    end

  end

  describe "image" do

    @valid_attrs %Plug.Upload{
      content_type: "image/jpg",
      filename: "cat.jpg",
      path: "test/support/files/cat-three.jpg"
    }
    @update_attrs %Plug.Upload{
      content_type: "image/jpg",
      filename: "another-cat.jpg",
      path: "test/support/files/cat-eight.jpg"
    }
    @invalid_attrs %Plug.Upload{
      content_type: nil,
      filename: nil,
      path: nil
    }

    def image_fixture(_attrs \\ %{}) do
      program = Factory.insert(:program, [], prefix: @prefix)

      assert {:ok, %Image{} = image} =
               Station.create_image_from_plug_upload(
                 program,
                 @valid_attrs,
                 @tenant
               )

      image
      |> Repo.preload(program: [])
    end

    test "get_document!/1 returns the document with given id" do
      image = image_fixture()
      assert Station.get_image!(image.id, @tenant) == image
    end

    test "create_image_from_plug/3 with valid data creates a document" do
      program = Factory.insert(:program, [], prefix: @prefix)

      assert {:ok, %Image{} = image} =
               Station.create_image_from_plug_upload(program, @valid_attrs, @tenant)

      assert image.content_type == "image/jpg"
      assert image.filename == "cat.jpg"
    end

    test "create_image_from_plug/3 with invalid data returns error changeset" do
      program = Factory.insert(:program, [], prefix: @prefix)

      assert {:error, _reason} = Station.create_image_from_plug_upload(program, @invalid_attrs, @tenant)
    end

    test "update_image_from_plug/3 with valid data updates the document" do
      image = image_fixture()

      assert {:ok, %Image{} = image} =
               Station.update_image_from_plug(image, @update_attrs, @tenant)

      assert image.content_type == "image/jpg"
      assert image.filename == "another-cat.jpg"
    end

    test "update_image_from_plug/3 with invalid data returns error changeset" do
      image = image_fixture()

      assert {:error, _reason} = Station.update_image_from_plug(image, @invalid_attrs, @tenant)

      assert image == Station.get_image!(image.id, @tenant)
    end

    test "get the image from the remote source" do
      image = image_fixture()

      expected_content = @valid_attrs.path |> File.read!()
      content = Station.download_from_s3(image.remote_filename)

      assert content == expected_content
    end
  end


end
