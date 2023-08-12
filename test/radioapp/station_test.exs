defmodule Radioapp.StationTest do
  use Radioapp.DataCase
  alias Radioapp.Factory

  alias Radioapp.Station
  alias Radioapp.Station.{Program, Timeslot, Log, Segment, Image}

  describe "programs" do
    @invalid_attrs %{description: nil, genre: nil, name: nil}

    test "list_programs/0 returns all programs" do
      program = Factory.insert(:program)
      assert Station.list_programs() == [program]
    end
    test "list_programs/0 with hide flag returns no programs" do
      _program = Factory.insert(:program, hide: true)
      assert Station.list_programs() == []
    end

    test "get_program!/1 returns the program with given id" do
      program = Factory.insert(:program)
      assert Station.get_program!(program.id) == program
    end

    test "create_program/1 with valid data creates a program" do
      valid_attrs = %{description: "some description", genre: "some genre", name: "some name", short_description: "some short description"}

      assert {:ok, %Program{} = program} = Station.create_program(valid_attrs)
      assert program.description == "some description"
      assert program.genre == "some genre"
      assert program.name == "some name"
      assert program.short_description == "some short description"
    end

    test "create_program/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Station.create_program(@invalid_attrs)
    end

    test "update_program/2 with valid data updates the program" do
      program = Factory.insert(:program)

      update_attrs = %{
        description: "some updated description",
        genre: "some updated genre",
        name: "some updated name",
        short_description: "some updated short description"
      }

      assert {:ok, %Program{} = program} = Station.update_program(program, update_attrs)
      assert program.description == "some updated description"
      assert program.genre == "some updated genre"
      assert program.name == "some updated name"
      assert program.short_description == "some updated short description"
    end

    test "update_program/2 with invalid data returns error changeset" do
      program = Factory.insert(:program)
      assert {:error, %Ecto.Changeset{}} = Station.update_program(program, @invalid_attrs)
      assert program == Station.get_program!(program.id)
    end

    test "delete_program/1 deletes the program" do
      program = Factory.insert(:program)
      assert {:ok, %Program{}} = Station.delete_program(program)
      assert_raise Ecto.NoResultsError, fn -> Station.get_program!(program.id) end
    end

    test "change_program/1 returns a program changeset" do
      program = Factory.insert(:program)
      assert %Ecto.Changeset{} = Station.change_program(program)
    end
  end

  describe "timeslots" do
    @invalid_attrs %{day: nil, endtime: nil, runtime: nil, starttime: nil}

    test "list_timeslots/0 returns all timeslots" do
      timeslot = Factory.insert(:timeslot)

      expected = [timeslot.id]
      assert expected == Enum.map(Station.list_timeslots(), fn t -> t.id end)
    end

    test "list_timeslots_for_program/0 returns all timeslots" do
      program1 = Factory.insert(:program)
      program2 = Factory.insert(:program)

      timeslot1 = Factory.insert(:timeslot, day: 1, program: program1)
      _timeslot2 = Factory.insert(:timeslot, day: 2, program: program2)

      expected = [timeslot1.id]
      assert expected == Enum.map(Station.list_timeslots_for_program(program1), fn t -> t.id end)
      refute expected == Enum.map(Station.list_timeslots_for_program(program2), fn t -> t.id end)
    end

    test "list_timeslots_by_day/0 returns all timeslots" do
      program1 = Factory.insert(:program)
      program2 = Factory.insert(:program)

      timeslot1 = Factory.insert(:timeslot, day: 1, program: program1)
      _timeslot2 = Factory.insert(:timeslot, day: 2, program: program2)

      expected = [timeslot1.id]
      assert expected == Enum.map(Station.list_timeslots_by_day(1), fn t -> t.id end)
      refute expected == Enum.map(Station.list_timeslots_by_day(2), fn t -> t.id end)
    end

    test "get_timeslot!/1 returns the timeslot with given id" do
      timeslot = Factory.insert(:timeslot)
      get_timeslot = Station.get_timeslot!(timeslot.id)
      assert get_timeslot.id == timeslot.id
    end

    test "create_timeslot/1 with valid data creates a timeslot" do
      program = Factory.insert(:program)

      valid_attrs = %{
        day: 2,
        runtime: 42,
        starttime: ~T[14:00:00],
        program: program
      }

      assert {:ok, %Timeslot{} = timeslot} = Station.create_timeslot(program, valid_attrs)
      assert timeslot.day == 2
      assert timeslot.runtime == 42
      assert timeslot.starttime == ~T[14:00:00]
      assert timeslot.endtime == ~T[14:42:00]
      assert timeslot.program_id == program.id
    end

    test "create_timeslot/1 with invalid data returns error changeset" do
      program = Factory.insert(:program)
      assert {:error, %Ecto.Changeset{}} = Station.create_timeslot(program, @invalid_attrs)
    end

    test "update_timeslot/2 with valid data updates the timeslot" do
      program = Factory.insert(:program)
      timeslot = Factory.insert(:timeslot, program: program)

      update_attrs = %{day: 43, endtime: ~T[15:01:01], runtime: 43, starttime: ~T[15:01:01]}

      assert {:ok, %Timeslot{} = timeslot} = Station.update_timeslot(timeslot, update_attrs)

      assert timeslot.day == 43
      assert timeslot.runtime == 43
      assert timeslot.starttime == ~T[15:01:01]
      assert timeslot.endtime == ~T[15:44:01]
      assert timeslot.program == program
    end

    test "update_timeslot/2 with invalid data returns error changeset" do
      timeslot = Factory.insert(:timeslot)
      assert {:error, %Ecto.Changeset{}} = Station.update_timeslot(timeslot, @invalid_attrs)
      get_timeslot = Station.get_timeslot!(timeslot.id)
      assert get_timeslot.id == timeslot.id
    end

    test "delete_timeslot/1 deletes the timeslot" do
      program = Factory.insert(:program)
      timeslot = Factory.insert(:timeslot)

      timeslot =
        timeslot
        |> Map.merge(%{
          program: program
        })

      assert {:ok, %Timeslot{}} = Station.delete_timeslot(timeslot)
      assert Station.get_program!(program.id) == program
      assert_raise Ecto.NoResultsError, fn -> Station.get_timeslot!(timeslot.id) end
    end

    test "change_timeslot/1 returns a timeslot changeset" do
      timeslot = Factory.insert(:timeslot)
      assert %Ecto.Changeset{} = Station.change_timeslot(timeslot)
    end
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
      song_title: "some song title"
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
      song_title: "some updated song title"
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
      song_title: nil
    }

    test "list_segments/0 returns all segments" do
      segment = Factory.insert(:segment)

      expected = [segment.id]
      assert expected == Enum.map(Station.list_segments(), fn s -> s.id end)
    end

    test "list_segments_for_log/0 returns all segments for a given log" do
      log1 = Factory.insert(:log)
      log2 = Factory.insert(:log)

      segment1 = Factory.insert(:segment, log: log1)
      _segment2 = Factory.insert(:segment, log: log2)

      expected = [segment1.id]
      assert expected == Enum.map(Station.list_segments_for_log(log1), fn s -> s.id end)
      refute expected == Enum.map(Station.list_segments_for_log(log2), fn s -> s.id end)
    end

    test "get_segment!/1 returns the segment with given id" do
      segment = Factory.insert(:segment)

      get_segment = Station.get_segment!(segment.id)
      assert get_segment.id == segment.id
    end

    test "create_segment/1 with valid data creates a segment" do
      program = Factory.insert(:program)
      log = Factory.insert(:log, program: program)
      _valid_category = Factory.insert(:category, id: 1)
      assert {:ok, %Segment{} = segment} = Station.create_segment(log, @valid_attrs)
      assert segment.can_con == true
      assert segment.catalogue_number == "12345"
      assert segment.start_time == ~T[02:11:00Z]
      assert segment.end_time == ~T[02:13:00Z]
      assert segment.hit == true
      assert segment.instrumental == false
      assert segment.new_music == true
      assert segment.song_title == "some song title"
    end

    test "create_segment/1 with invalid data returns error changeset" do
      program = Factory.insert(:program)
      log = Factory.insert(:log, program: program)
      assert {:error, %Ecto.Changeset{}} = Station.create_segment(log, @invalid_attrs)
    end

    test "update_segment/2 with valid data updates the segment" do
      segment = Factory.insert(:segment)
      _update_category = Factory.insert(:category, id: 2)
      assert {:ok, %Segment{} = segment} = Station.update_segment(segment, @update_attrs)
      assert segment.can_con == false
      assert segment.catalogue_number == "54321"
      assert segment.start_time == ~T[03:11:00Z]
      assert segment.end_time == ~T[03:13:00Z]
      assert segment.hit == false
      assert segment.instrumental == true
      assert segment.new_music == false
      assert segment.song_title == "some updated song title"
    end

    test "update_segment/2 with invalid data returns error changeset" do
      segment = Factory.insert(:segment)
      assert {:error, %Ecto.Changeset{}} = Station.update_segment(segment, @invalid_attrs)

      get_segment = Station.get_segment!(segment.id)
      assert get_segment.id == segment.id
    end

    test "delete_segment/1 deletes the segment" do
      segment = Factory.insert(:segment)
      assert {:ok, %Segment{}} = Station.delete_segment(segment)
      assert_raise Ecto.NoResultsError, fn -> Station.get_segment!(segment.id) end
    end

    test "change_segment/1 returns a segment changeset" do
      segment = Factory.insert(:segment)
      assert %Ecto.Changeset{} = Station.change_segment(segment)
    end
  end

  describe "logs" do
    @valid_attrs %{
      host_name: "some host name",
      notes: "some notes",
      category: "Popular Music",
      date: ~D[2023-02-18],
      start_time: ~T[01:11:00Z],
      end_time: ~T[01:13:00Z],
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
      program = Factory.insert(:program)
      log = Factory.insert(:log, program: program)

      expected = [log.id]
      assert expected == Enum.map(Station.list_logs(), fn s -> s.id end)
    end

    test "list_logs_for_timeslot/0 returns all logs" do
      program1 = Factory.insert(:program)
      program2 = Factory.insert(:program)

      log1 = Factory.insert(:log, program: program1)
      _log2 = Factory.insert(:log, program: program2)

      expected = [log1.id]
      assert expected == Enum.map(Station.list_logs_for_program(program1), fn s -> s.id end)
      refute expected == Enum.map(Station.list_logs_for_program(program2), fn s -> s.id end)
    end

    test "get_log!/1 returns the log with given id" do
      log = Factory.insert(:log)
      get_log = Station.get_log!(log.id)

      assert get_log.id == log.id
    end

    test "create_log/1 with valid data creates a log" do
      program = Factory.insert(:program)

      assert {:ok, %Log{} = log} = Station.create_log(program, @valid_attrs)
      assert log.notes == "some notes"
      assert log.category == "Popular Music"
      assert log.date == ~D[2023-02-18]
      assert log.start_time == ~T[01:11:00Z]
      assert log.end_time == ~T[01:13:00Z]
      assert log.language == "English"
    end

    test "create_log/1 with invalid data returns error changeset" do
      program = Factory.insert(:program)
      assert {:error, %Ecto.Changeset{}} = Station.create_log(program, @invalid_attrs)
    end

    test "update_log/2 with valid data updates the log" do
      log = Factory.insert(:log)

      assert {:ok, %Log{} = log} = Station.update_log(log, @update_attrs)

      assert log.notes == "some updated notes"
      assert log.category == "Spoken Word"
      assert log.date == ~D[2023-03-18]
      assert log.start_time == ~T[02:11:00Z]
      assert log.end_time == ~T[02:13:00Z]
      assert log.language == "French"
    end

    test "update_log/2 with invalid data returns error changeset" do
      log = Factory.insert(:log)
      assert {:error, %Ecto.Changeset{}} = Station.update_log(log, @invalid_attrs)
      get_log = Station.get_log!(log.id)

      assert get_log.id == log.id
    end

    test "delete_log/1 deletes the log" do
    log = Factory.insert(:log)
      assert {:ok, %Log{}} = Station.delete_log(log)
      assert_raise Ecto.NoResultsError, fn -> Station.get_log!(log.id) end
    end

    test "change_log/1 returns a log changeset" do
      log = Factory.insert(:log)
      assert %Ecto.Changeset{} = Station.change_log(log)
    end
  end

  test "#talking_segments_minutes" do
    # Given a log we're interested in
    log = Factory.insert(:log)

    # And it has a number of segments
    category = Factory.insert(:category, code: "11")
    Factory.insert(:segment,
      log: log,
      category: category,
      start_time: ~T[02:13:25Z],
      end_time: ~T[02:15:40Z]
    )

    Factory.insert(:segment,
      log: log,
      category: category,
      start_time: ~T[14:12:00Z],
      end_time: ~T[15:15:00Z]
    )

    other_category = Factory.insert(:category, code: "21")
    Factory.insert(:segment,
      log: log,
      category: other_category,
      new_music: true,
      start_time: ~T[14:12:00Z],
      end_time: ~T[15:15:00Z]
    )

    # And another log we're not interested in
    other_log = Factory.insert(:log)

    # And it also has a number of segments
    Factory.insert(:segment, log: other_log, category: category)
    Factory.insert(:segment, log: other_log, category: other_category)

    # When we ask for the music minutes for the log we're interested in
    # Then we see the sum of the duration of those segments
    # 65 minutes.
    assert Station.talking_segments(log) == 3915
  end

  test "tracking minutes of segments" do


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
      program = Factory.insert(:program)

      assert {:ok, %Image{} = image} =
               Station.create_image_from_plug_upload(
                 program,
                 @valid_attrs
               )

      image
      |> Repo.preload(program: [])
    end

    test "get_document!/1 returns the document with given id" do
      image = image_fixture()
      assert Station.get_image!(image.id) == image
    end

    test "create_image_from_plug/3 with valid data creates a document" do
      program = Factory.insert(:program)

      assert {:ok, %Image{} = image} =
               Station.create_image_from_plug_upload(program, @valid_attrs)

      assert image.content_type == "image/jpg"
      assert image.filename == "cat.jpg"
    end

    test "create_image_from_plug/3 with invalid data returns error changeset" do
      program = Factory.insert(:program)

      assert {:error, _reason} = Station.create_image_from_plug_upload(program, @invalid_attrs)
    end

    test "update_image_from_plug/3 with valid data updates the document" do
      image = image_fixture()

      assert {:ok, %Image{} = image} =
               Station.update_image_from_plug(image, @update_attrs)

      assert image.content_type == "image/jpg"
      assert image.filename == "another-cat.jpg"
    end

    test "update_image_from_plug/3 with invalid data returns error changeset" do
      image = image_fixture()

      assert {:error, _reason} = Station.update_image_from_plug(image, @invalid_attrs)

      assert image == Station.get_image!(image.id)
    end

    test "get the image from the remote source" do
      image = image_fixture()

      expected_content = @valid_attrs.path |> File.read!()
      content = Station.download_from_s3(image.remote_filename)

      assert content == expected_content
    end
  end
end
