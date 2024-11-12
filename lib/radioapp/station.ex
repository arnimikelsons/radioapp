defmodule Radioapp.Station do
  @moduledoc """
  The Station context.
  """

  import Ecto.Query, warn: false
  alias Radioapp.Repo
  alias Radioapp.Admin

  alias Radioapp.Station.{Program, Timeslot, Segment, Log, Image, PlayoutSegment}

  @doc """
  Returns the list of programs.

  ## Examples

      iex> list_programs()
      [%Program{}, ...]

  """
  def list_programs(tenant) do
    from(p in Program, where: p.hide == false or is_nil(p.hide), order_by: [asc: :name])
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload([
      :timeslots,
      :images,
      :link1,
      :link2,
      :link3
    ])
    
  end

  def list_all_programs(tenant) do
    program = from(p in Program, order_by: [asc: :name])
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload([
      :timeslots,
      :images,
      :link1,
      :link2,
      :link3
    ])

    for p <- program do 
      %{p | timeslot_count: Enum.count(p.timeslots)} 
    end
  end

  def list_programs_with_timeslot(program) do
    for p when p.timeslot_count > 0 <- program do
       p
    end
  end
  def list_programs_with_no_timeslots(program) do
    for p when p.timeslot_count == 0 <- program do
       p
    end
  end
  def list_programs_not_hidden(program) do
    for p when p.hide == false <- program do
       p
    end
  end
  def list_programs_hidden(program) do
    for p when p.hide == true <- program do
       p
    end
  end
  def select_programs(params, raw_programs, _tenant) do
    _list_programs = case params.select_filter do
        "programs with timeslots" -> list_programs_with_timeslot(raw_programs)
        "programs with no timeslots" -> list_programs_with_no_timeslots(raw_programs)
        "use hidden checkbox" -> list_programs_not_hidden(raw_programs)
        "show hidden programs" -> list_programs_hidden(raw_programs)
        _ -> raw_programs
      end   
    

  end

  @doc """
  Gets a single program.

  Raises `Ecto.NoResultsError` if the Program does not exist.

  ## Examples

      iex> get_program!(123)
      %Program{}

      iex> get_program!(456)
      ** (Ecto.NoResultsError)

  """
  def get_program!(id, tenant) do
    p = Program
    |> Repo.get!(id, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload([
      :timeslots,
      :images,
      :link1,
      :link2,
      :link3
    ])
    %{p | timeslot_count: Enum.count(p.timeslots)} 
  end

  def get_program_from_time(weekday, time_now, tenant) do
    from(t in Timeslot,
      join: p in assoc(t, :program),
      where: t.day == ^weekday,
      where: t.starttime <= ^time_now,
      where: t.endtime > ^time_now,
      select: p.name
    )
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
  end

  # A new one that includes helper functions to determine now playing show
  # based on Timezone set in stationdefaults

  def get_program_from_time(tenant) do

    %{timezone: timezone} = Admin.get_timezone!(tenant)
    now = DateTime.to_naive(Timex.now(timezone))
    time_now = DateTime.to_time(Timex.now(timezone))
    weekday = Timex.weekday(now)

    query = from(t in Timeslot,
      join: p in assoc(t, :program),
      where: t.day == ^weekday,
      where: t.starttime <= ^time_now,
      where: t.endtime > ^time_now,
      select: p.name
    )

    Repo.all(query, prefix: Triplex.to_prefix(tenant))

  end

  def get_program_now_start_time(weekday, time_now, tenant) do
    from(t in Timeslot,
      join: p in assoc(t, :program),
      where: t.day == ^weekday,
      where: t.starttime <= ^time_now,
      where: t.endtime >= ^time_now,
      select: t.starttimereadable
    )
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
  end

  def get_program_now_start_time(tenant) do
    %{timezone: timezone} = Admin.get_timezone!(tenant)
    now = DateTime.to_naive(Timex.now(timezone))
    time_now = DateTime.to_time(Timex.now(timezone))
    weekday = Timex.weekday(now)

    from(t in Timeslot,
    join: p in assoc(t, :program),
    where: t.day == ^weekday,
    where: t.starttime <= ^time_now,
    where: t.endtime >= ^time_now,
    select: t.starttimereadable
  )
  |> Repo.all(prefix: Triplex.to_prefix(tenant))
  end


  @doc """
  Creates a program.

  ## Examples

      iex> create_program(%{field: value})
      {:ok, %Program{}}

      iex> create_program(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_program(attrs \\ %{}, tenant) do
    %Program{}
    |> Program.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Updates a program.

  ## Examples

      iex> update_program(program, %{field: new_value})
      {:ok, %Program{}}

      iex> update_program(program, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_program(%Program{} = program, attrs) do
    program
    |> Program.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a program.

  ## Examples

      iex> delete_program(program)
      {:ok, %Program{}}

      iex> delete_program(program)
      {:error, %Ecto.Changeset{}}

  """
  def delete_program(%Program{} = program) do
    Repo.delete(program)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking program changes.

  ## Examples

      iex> change_program(program)
      %Ecto.Changeset{data: %Program{}}

  """
  def change_program(%Program{} = program, attrs \\ %{}) do
    Program.changeset(program, attrs)
  end

  @doc """
  Returns the list of timeslots.

  ## Examples

      iex> list_timeslots()
      [%Timeslot{}, ...]

  """

  def list_timeslots(tenant) do
    # from(p in Timeslot, order_by: [asc: :name])
    from(t in Timeslot, order_by: [asc: :day, asc: :starttime])
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(
      program: [
        link1: [],
        link2: [],
        link3: []
      ]
    )
  end

  def list_timeslots_for_program(program, tenant) do
    from(t in Timeslot, where: [program_id: ^program.id], order_by: [asc: :day])
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(program: [link1: [], link2: [], link3: []])
  end

  def list_timeslots_for_archives_from_logs(program, tenant) do
    stationdefaults = Admin.get_stationdefaults!(tenant)
    now = Timex.now(stationdefaults.timezone)
    log_start = Timex.shift(now, weeks: -stationdefaults.weeks_of_archives)
    raw_logs =
    from(l in Log, 
      where: l.program_id  == ^program.id, 
      where: l.start_datetime >= ^log_start,
      order_by: [desc: :date],

      select: %{ 
        startdatetime: l.start_datetime, 
        enddatetime: l.end_datetime
      }
      # l.date, 
      # starttime: l.start_time,
      # enddatetime: l.end_datetime}
      # could use runtime, but end_time might be just as useful
      # need to have starttimereadable and starttime
    )
    |> Repo.all(prefix: Triplex.to_prefix(tenant))

    stationdefaults = Admin.get_stationdefaults!(tenant)

    _today = Timex.today(stationdefaults.timezone)
    
    rough_timeslots =
      for l <- raw_logs do
        kday_date = Timex.to_date(l.startdatetime)
        runtime = DateTime.diff(l.startdatetime, l.enddatetime)*60
        starttime = DateTime.to_time(l.startdatetime)
        starttimereadable = Timex.format!(l.startdatetime, "{h12}:{0m} {am}")

        cond do
          runtime > 120 ->
            [%{date: Calendar.strftime(kday_date, "%B %d %Y"), starttime: "at #{starttimereadable}", audio_url: build_audio_url(kday_date, starttime, tenant)}] ++
            [%{date: Calendar.strftime(kday_date, "%B %d %Y"), starttime: "Hour 2", audio_url: build_audio_url(kday_date, Time.add(starttime, 3600), tenant)}] ++
            [%{date: Calendar.strftime(kday_date, "%B %d %Y"), starttime: "Hour 3", audio_url: build_audio_url(kday_date, Time.add(starttime, 7200), tenant)}]
          runtime > 60 ->
            [%{date: Calendar.strftime(kday_date, "%B %d %Y"), starttime: "at #{starttimereadable}", audio_url: build_audio_url(kday_date, starttime, tenant)}] ++
            [%{date: Calendar.strftime(kday_date, "%B %d %Y"), starttime: "Hour 2", audio_url: build_audio_url(kday_date, Time.add(starttime, 3600), tenant)}]
          true ->
            [%{date: Calendar.strftime(kday_date, "%B %d %Y"), starttime: "at #{starttimereadable}", audio_url: build_audio_url(kday_date, starttime, tenant)}]
        end
      end

    all_logs = Enum.flat_map(rough_timeslots, &(&1))

    full_timeslots = Enum.with_index(all_logs, fn element, index -> Map.put(element, :id, index) end)
    {full_timeslots}
  end

  def list_timeslots_for_archives(program, tenant) do
    # from timeslots, loop over the last x weeks to output the archives that can be played

    raw_timeslots = from(t in Timeslot, 
      where: [program_id: ^program.id],
      order_by: [desc: t.day, asc: t.starttime],
      select: %{
      day: t.day,
      starttime: t.starttime, 
      starttimereadable: t.starttimereadable,
      runtime: t.runtime
    })
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    stationdefaults = Admin.get_stationdefaults!(tenant)

    # Find today; find # of weeks for archive from settings, find that day
    # Loop over days starting at today, going back to end day, and out
    # Output date, so a URL can be assembled, or assemble the URL
    today = Timex.today(stationdefaults.timezone)
    tz = Timex.now(stationdefaults.timezone)
    beginning_of_week = Date.beginning_of_week(tz)
    all_timeslots = for x <- 0..-stationdefaults.weeks_of_archives do
      timeslot_date = beginning_of_week |> Timex.shift(weeks: x)
      
      rough_timeslots = for t <- raw_timeslots do
        kday_date = Kday.kday_on_or_before(timeslot_date,t.day)
        t_date = kday_date |> Timex.shift(days: -1)
        if Timex.before?(t_date, today) do
          cond do
            t.runtime > 120 ->
              [%{date: Calendar.strftime(kday_date, "%B %d %Y"), starttime: "at #{t.starttimereadable}", audio_url: build_audio_url(kday_date, t.starttime, tenant)}] ++
              [%{date: Calendar.strftime(kday_date, "%B %d %Y"), starttime: "Hour 2", audio_url: build_audio_url(kday_date, Time.add(t.starttime, 3600), tenant)}] ++
              [%{date: Calendar.strftime(kday_date, "%B %d %Y"), starttime: "Hour 3", audio_url: build_audio_url(kday_date, Time.add(t.starttime, 7200), tenant)}]
            t.runtime > 60 ->
              [%{date: Calendar.strftime(kday_date, "%B %d %Y"), starttime: "at #{t.starttimereadable}", audio_url: build_audio_url(kday_date, t.starttime, tenant)}] ++
              [%{date: Calendar.strftime(kday_date, "%B %d %Y"), starttime: "Hour 2", audio_url: build_audio_url(kday_date, Time.add(t.starttime, 3600), tenant)}]
            true ->
              [%{date: Calendar.strftime(kday_date, "%B %d %Y"), starttime: "at #{t.starttimereadable}", audio_url: build_audio_url(kday_date, t.starttime, tenant)}]
          end
        else 
          [%{date: nil, starttime: nil, audio_url: nil}]
        end
      end
      _timeslots = Enum.flat_map(rough_timeslots, &(&1))
    end
    f_timeslots = Enum.flat_map(all_timeslots, &(&1))
    full_timeslots = Enum.with_index(f_timeslots, fn element, index -> Map.put(element, :id, index) end)
    {full_timeslots}
  end

  def build_audio_url(date, starttime, tenant) do
    case tenant do
      "cfrc" -> 
        {:ok, datetime} = NaiveDateTime.new(date, starttime)
        audio_datetime = Calendar.strftime(datetime, "%Y-%m-%d-%H")
        _audio_url = "https://audio.cfrc.ca/archives/#{audio_datetime}.mp3"
      "radio" -> 
        {:ok, datetime} = NaiveDateTime.new(date, starttime)
        audio_datetime = Calendar.strftime(datetime, "%Y-%m-%d-%H")
        _audio_url = "https://audio.cfrc.ca/archives/#{audio_datetime}.mp3"
      "sample" -> 
        # for tests
        {:ok, datetime} = NaiveDateTime.new(date, starttime)
        audio_datetime = Calendar.strftime(datetime, "%Y-%m-%d-%H")
        _audio_url = "https://someurl.ca/archives/#{audio_datetime}.mp3"  
      _ ->
        _audio_url = nil
    end

  end

  def list_timeslots_by_day(day, tenant) do
    from(t in Timeslot, where: t.day == ^day, order_by: [asc: :starttime])
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(program: [link1: [], link2: [], link3: []])
  end

  @doc """
  Gets a single timeslot.

  Raises `Ecto.NoResultsError` if the Timeslot does not exist.

  ## Examples

      iex> get_timeslot!(123)
      %Timeslot{}

      iex> get_timeslot!(456)
      ** (Ecto.NoResultsError)

  """
  def get_timeslot!(id, tenant) do
    Timeslot
    |> Repo.get!(id, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:program)
  end

  @doc """
  Creates a timeslot.

  ## Examples

      iex> create_timeslot(%{field: value})
      {:ok, %Timeslot{}}

      iex> create_timeslot(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_timeslot(%Program{} = program, attrs \\ %{}, tenant) do
    program
    |> Ecto.build_assoc(:timeslots)
    |> Timeslot.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Updates a timeslot.

  ## Examples

      iex> update_timeslot(timeslot, %{field: new_value})
      {:ok, %Timeslot{}}

      iex> update_timeslot(timeslot, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_timeslot(%Timeslot{} = timeslot, attrs) do
    timeslot
    |> Timeslot.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a timeslot.

  ## Examples

      iex> delete_timeslot(timeslot)
      {:ok, %Timeslot{}}

      iex> delete_timeslot(timeslot)
      {:error, %Ecto.Changeset{}}

  """
  def delete_timeslot(%Timeslot{} = timeslot) do
    Repo.delete(timeslot)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking timeslot changes.

  ## Examples

      iex> change_timeslot(timeslot)
      %Ecto.Changeset{data: %Timeslot{}}

  """
  def change_timeslot(%Timeslot{} = timeslot, attrs \\ %{}) do
    Timeslot.changeset(timeslot, attrs)
  end

  @doc """
  Returns the list of logs.

  ## Examples

      iex> list_logs()
      Log{}, ...]

  """
  def list_logs(tenant) do
    Log
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:program)
  end

  def list_logs_date_conversion(tenant) do
    _logs = from(s in Log,
      where: is_nil(s.start_datetime),
      or_where: is_nil(s.end_datetime)
    )
    |> Repo.all(prefix: Triplex.to_prefix(tenant))

  end

  def update_logs_date_conversion(tenant) do
    logs = from(s in Log,
      where: is_nil(s.start_datetime),
      or_where: is_nil(s.end_datetime)
    )
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:program)

    _updated_logs = Enum.each(logs, fn(x) ->
      update_log_utc(x, tenant)
    end)
  end

  def list_logs_for_program(program, tenant) do
    from(l in Log, where: [program_id: ^program.id], order_by: [desc: :date])
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:program)
  end

  def list_full_logs(params, tenant) do
    from(s in Segment,
      join: l in assoc(s, :log),
      join: p in assoc(l, :program),
      where: l.date >= ^params.start_date,
      where: l.date <= ^params.end_date,
      order_by: [asc: l.date]
    )
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(log: [:program], category: [])
  end


  def list_playout_segments_by_log(log, tenant) do

    from(p in PlayoutSegment,
      where: p.inserted_at >= ^log.start_datetime,
      where: p.inserted_at <= ^log.end_datetime,
      order_by: [asc: p.inserted_at]
    )
    |> Repo.all(prefix: Triplex.to_prefix(tenant))

  end

  def list_charts(params, tenant) do
    charts_query =
      from(s in Segment,
        inner_join: l in assoc(s, :log),
        inner_join: c in assoc(s, :category),
        where: l.date >= ^params.start_date,
        where: l.date <= ^params.end_date,
        where: fragment("CAST(?.code as integer) between 20 and 39", c),
        group_by: [s.artist, s.song_title],
        order_by: [desc: count(s.song_title)],
        select: %{
          artist: s.artist,
          song_title: s.song_title,
          count: count(s.song_title)
        }
      )

    Repo.all(charts_query, prefix: Triplex.to_prefix(tenant))
  end
  

  def previous_month(%Date{day: day} = date) do
    days = max(day, Date.add(date, -day).day)
    Date.add(date, -days)
  end

  def previous_week(date) do
    Date.add(date, -7)
  end


  @doc """
  Gets a single log.

  Raises `Ecto.NoResultsError` if the Log does not exist.

  ## Examples

      iex> get_log!(123)
      %Log{}

      iex> get_log!(456)
      ** (Ecto.NoResultsError)

  """

  def get_log!(id, tenant) do
    Log
    |> Repo.get!(id, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:program)
  end

  @doc """
  Creates a log.

  ## Examples

      iex> create_log(%Program{} = program, %{field: value}, tenant)
      {:ok, %Log{}}

      iex> create_log((%Program{} = program, %{field: bad_value}, tenant)
      {:error, %Ecto.Changeset{}}

  """

  def create_log(%Program{} = program, attrs \\ %{}, tenant) do

    case add_utc_to_attrs(attrs, tenant) do

      {:ok, attrs} ->
          program
          |> Ecto.build_assoc(:logs)
          |> Log.changeset(attrs)
          |> Repo.insert(prefix: Triplex.to_prefix(tenant))

      {:error, _message} ->
          changeset =
            program
            |> Ecto.build_assoc(:logs)
            |> Log.changeset(attrs)

          {:error, changeset}

    end
  end

  @doc """
  Updates a log.

  ## Examples

      iex> update_log(log, %{field: new_value}, tenant)
      {:ok, %Log{}}

      iex> update_log(log, %{field: bad_value}, tenant)
      {:error, %Ecto.Changeset{}}

  """
  def update_log(%Log{} = log, attrs, tenant) do

    case add_utc_to_attrs(attrs, tenant) do

      {:ok, attrs} ->
        log
        |> Log.changeset(attrs)
        |> Repo.update()

      {:error, _message} ->
          changeset =
            log
            |> Log.changeset(attrs)

          {:error, changeset}

    end

  end
  def update_log_utc(%Log{} = log, tenant) do
    date = Date.to_string(log.date)
    start_time = Time.to_string(log.start_time)
    end_time = Time.to_string(log.end_time)

    {:ok, start_datetime, end_datetime} = add_utc(date, start_time, end_time, tenant)
    attrs = %{start_datetime: start_datetime, end_datetime: end_datetime }

    _updated = log
    |> Log.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a log.

  ## Examples

      iex> delete_log(log)
      {:ok, %Log{}}

      iex> delete_log(log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_log(%Log{} = log) do
    Repo.delete(log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking log changes.

  ## Examples

      iex> change_log(log)
      %Ecto.Changeset{data: %Log{}}

  """
  def change_log(%Log{} = log, attrs \\ %{}) do
    Log.changeset(log, attrs)
  end


  @doc """
  Adds UTC values to a log attrs.

  ## Examples

      iex> add_utc_to_attrs(%{"date" => value, "start_time" => value, "end_time" = value} = attrs)
      {:ok, attrs}

      iex> add_utc_to_attrs(%{field: bad_value})
      {:error, "Missing \#{value}"}

  """
  def add_utc_to_attrs(%{"date" => date, "start_time" => start_time, "end_time" => end_time } = attrs, tenant) do
    
    case add_utc(date, start_time, end_time, tenant) do
      {:ok, start_datetime, end_datetime} ->
        attrs =
          attrs
          |> Map.put("start_datetime", start_datetime)
          |> Map.put("end_datetime", end_datetime)

        {:ok, attrs}

      {:error, message} ->
        {:error, message}
    end
  end

  def add_utc_to_attrs(%{date: date, start_time: start_time, end_time: end_time } = attrs, tenant) do

    case add_utc(date, start_time, end_time, tenant) do
      {:ok, start_datetime, end_datetime} ->
        attrs =
          attrs
          |> Map.put("start_datetime", start_datetime)
          |> Map.put("end_datetime", end_datetime)

        {:ok, attrs}

      {:error, message} ->
        {:error, message}
      end
  end

  def add_utc_to_attrs(%{"artist" => _artist,  "date" => _date, "song_title" => _song_title, "start_datetime" => _start_datetime} = attrs, _tenant) do
    {:ok, attrs}
  end

  defp add_utc(date, start_time, end_time, tenant) do
    %{timezone: station_timezone} = Admin.get_timezone!(tenant)
    case start_time == "" or end_time == "" do
      true ->
        start_datetime = nil
        end_datetime = nil
        {:ok, start_datetime, end_datetime}
        
      false ->
        case not is_nil(date) and not is_nil(start_time) and not is_nil(end_time) do
          true ->
            # Fix start time error missing seconds value
            start_time =
              case String.length(start_time) do
                5 ->
                  start_time <> ":00"
                7 ->
                  "0#{start_time}"
                8 ->
                  start_time
                _ ->
                  ""
              end

            # Convert start_datetime to UTC
            {:ok, start_date_time_naive} = NaiveDateTime.from_iso8601("#{date} #{start_time}")
            {:ok, start_datetime} = DateTime.from_naive(start_date_time_naive, station_timezone)

            # Fix end time error missing seconds value
            end_time =
              case String.length(end_time) do
                5 ->
                  end_time <> ":00"
                7 ->
                  "0#{end_time}"
                8 ->
                  end_time
                _ ->
                  nil
              end
            # Convert end_datetime to UTC

            {:ok, end_date_time_naive} = NaiveDateTime.from_iso8601("#{date} #{end_time}")
            {:ok, end_datetime} = DateTime.from_naive(end_date_time_naive, station_timezone)

            {:ok, start_datetime, end_datetime}
          false ->
            {:error, "Missing date and/or time"}

          end
      end
    end

  @doc """
  Returns the list of segments.

  ## Examples

      iex> list_segments()
      [%Segment{}, ...]

  """


  def list_segments(tenant) do
    Repo.all(Segment, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload([:category, log: [:program]])
  end

  def list_segments_date_conversion(tenant) do
    _segments = from(s in Segment,
      where: is_nil(s.start_datetime),
      or_where: is_nil(s.end_datetime)
    )
    |> Repo.all(prefix: Triplex.to_prefix(tenant))

  end

  def update_segments_date_conversion(tenant) do
    segments = from(s in Segment,
      where: is_nil(s.start_datetime),
      or_where: is_nil(s.end_datetime)
    )
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:log)

    _updated_segments = Enum.each(segments, fn(x) ->
      update_segment_utc(x, tenant)
    end)
  end

  def list_segments_for_date(%{"start_date" => start_date, "end_date" => end_date}, tenant) do
    from(s in Segment,
      join: l in assoc(s, :log),
      left_join: c in assoc(s, :category),
      join: p in assoc(l, :program),
      where: l.date >= ^start_date,
      where: l.date <= ^end_date,
      order_by: [asc: :start_time],
      select: %{
        start_time: s.start_time, 
        end_time: s.end_time,
        program_name: p.name,
        host_name: l.host_name,
        log_category: l.category,
        date: l.date,
        log_start_time: l.start_time,
        log_end_time: l.end_time,
        language: l.language,
        start_time: s.start_time,
        end_time: s.end_time,
        category: c.code,
        category_name: c.name,
        artist: s.artist,
        song_title: s.song_title,
        catalogue_number: s.catalogue_number,
        socan_type: s.socan_type,
        new_music: s.new_music,
        instrumental: s.instrumental,
        can_con: s.can_con,
        hit: s.hit,
        indigenous_artist: s.indigenous_artist,
        emerging_artist: s.emerging_artist
      }
    )
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
  end

  def list_segments_for_log(log, tenant) do
    from(s in Segment, where: [log_id: ^log.id], order_by: [asc: :start_time])
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload([:category, log: [:program]])
  end

  def list_segments_for_log_export(log, tenant) do
    _segments = from(s in Segment, 
      left_join: c in assoc(s, :category),
      where: s.log_id == ^log.id, 
      order_by: [asc: :start_time],
      select: %{
        start_time: s.start_time,
        end_time: s.end_time,
        artist: s.artist,
        song_title: s.song_title,
        category: c.code,
        # category_name: c.name,
        catalogue_number: s.catalogue_number,
        socan_type: s.socan_type,
        new_music: s.new_music,
        instrumental: s.instrumental,
        can_con: s.can_con,
        hit: s.hit,
        indigenous_artist: s.indigenous_artist,
        emerging_artist: s.emerging_artist}
    )
    |> Repo.all(prefix: Triplex.to_prefix(tenant))

  end



  def start_time_of_next_segment(log, tenant) do
    query =
      from s in Segment,
        where: [log_id: ^log.id],
        select: max(s.end_time)

    Repo.one(query, prefix: Triplex.to_prefix(tenant)) || log.start_time
  end

  def talking_segments(log, tenant) do
    query =
      from(s in Segment,
        left_join: c in assoc(s, :category),
        where: c.code >= "10",
        where: c.code <= "19",
        where: [log_id: ^log.id],
        select: %{
          duration: sum(s.end_time - s.start_time)
        }
      )

    case Repo.one(query, prefix: Triplex.to_prefix(tenant)) do
      %{duration: %{secs: seconds}} ->
        seconds

      %{duration: nil} ->
        0
    end
  end

  def formatted_length(length) do
    "#{div(length, 60)}:#{formatted_seconds(rem(length, 60))}"
  end

  defp formatted_seconds(s) when s == 0, do: "00"
  defp formatted_seconds(s) when s < 10, do: "0#{s}"
  defp formatted_seconds(s), do: "#{s}"

  def track_minutes(log, tenant) do
    [count_music_tracks] =
      from(s in Segment,
        left_join: c in assoc(s, :category),
        where: [log_id: ^log.id],
        where: c.code >= "20",
        where: c.code <= "39",
        select: count(s.id)
      )
      |> Repo.all(prefix: Triplex.to_prefix(tenant))

    [new_music_tracks] =
      from(s in Segment,
        left_join: c in assoc(s, :category),
        where: [log_id: ^log.id],
        where: s.new_music == true,
        where: c.code >= "20",
        where: c.code <= "39",
        select: count(s.id)
      )
      |> Repo.all(prefix: Triplex.to_prefix(tenant))

    new_music =
      case count_music_tracks do
        0 -> 0
        _ -> Decimal.round(Decimal.from_float(new_music_tracks / count_music_tracks * 100))
      end

    [can_con_tracks] =
      from(s in Segment,
        left_join: c in assoc(s, :category),
        where: [log_id: ^log.id],
        where: s.can_con == true,
        where: c.code >= "20",
        where: c.code <= "39",
        select: count(s.id)
      )
      |> Repo.all(prefix: Triplex.to_prefix(tenant))

    can_con_music =
      case count_music_tracks do
        0 -> 0
        _ -> Decimal.round(Decimal.from_float(can_con_tracks / count_music_tracks * 100))
      end

    [instrumental_tracks] =
      from(s in Segment,
        left_join: c in assoc(s, :category),
        where: [log_id: ^log.id],
        where: s.instrumental == true,
        where: c.code >= "20",
        where: c.code <= "39",
        select: count(s.id)
      )
      |> Repo.all(prefix: Triplex.to_prefix(tenant))

    instrumental_music =
      case count_music_tracks do
        0 -> 0
        _ -> Decimal.round(Decimal.from_float(instrumental_tracks / count_music_tracks * 100))
      end

    [hit_tracks] =
      from(s in Segment,
        left_join: c in assoc(s, :category),
        where: [log_id: ^log.id],
        where: s.hit == true,
        where: c.code >= "20",
        where: c.code <= "39",
        select: count(s.id)
      )
      |> Repo.all(prefix: Triplex.to_prefix(tenant))

    hit_music =
      case count_music_tracks do
        0 -> 0
        _ -> Decimal.round(Decimal.from_float(hit_tracks / count_music_tracks * 100))
      end

    [indigenous_tracks] =
      from(s in Segment,
        left_join: c in assoc(s, :category),
        where: [log_id: ^log.id],
        where: s.indigenous_artist == true,
        where: c.code >= "20",
        where: c.code <= "39",
        select: count(s.id)
      )
      |> Repo.all(prefix: Triplex.to_prefix(tenant))

    indigenous_artist =
      case count_music_tracks do
        0 -> 0
        _ -> Decimal.round(Decimal.from_float(indigenous_tracks / count_music_tracks * 100))
      end


    [emerging_tracks] =
      from(s in Segment,
        left_join: c in assoc(s, :category),
        where: [log_id: ^log.id],
        where: s.emerging_artist == true,
        where: c.code >= "20",
        where: c.code <= "39",
        select: count(s.id)
      )
      |> Repo.all(prefix: Triplex.to_prefix(tenant))

    emerging_artist =
      case count_music_tracks do
        0 -> 0
        _ -> Decimal.round(Decimal.from_float(emerging_tracks / count_music_tracks * 100))
      end

    [new_music, can_con_music, instrumental_music, hit_music, indigenous_artist, emerging_artist]
  end

  @doc """
  Gets a single segment.

  Raises `Ecto.NoResultsError` if the Segment does not exist.

  ## Examples

      iex> get_segment!(123)
      %Segment{}

      iex> get_segment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_segment!(id, tenant) do
    Segment
    |> Repo.get!(id, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload([:category, log: [:program]])
  end

  @doc """
  Creates a segment.

  ## Examples

      iex> create_segment(%{field: value})
      {:ok, %Segment{}}

      iex> create_segment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_segment(%Log{} = log, attrs \\ %{}, tenant) do

    attrs =
      attrs
      |> Map.put("date", log.date)

    case add_utc_to_attrs(attrs, tenant) do
      {:ok, attrs} ->
        log
        |> Ecto.build_assoc(:segments)
        |> Segment.changeset(attrs)
        |> Repo.insert(prefix: Triplex.to_prefix(tenant))
      {:error, _message} ->
        changeset =
          log
          |> Ecto.build_assoc(:segments)
          |> Segment.changeset(attrs)
        {:error, changeset}
    end

  end

  def create_segment_relaxed(%Log{} = log, attrs \\ %{}, tenant) do

    attrs =
      attrs
      |> Map.put("date", log.date)

    case add_utc_to_attrs(attrs, tenant) do
      {:ok, attrs} ->
        log
        |> Ecto.build_assoc(:segments)
        |> Segment.changeset_relaxed(attrs)
        |> Repo.insert(prefix: Triplex.to_prefix(tenant))
      {:error, _message} ->
        changeset =
          log
          |> Ecto.build_assoc(:segments)
          |> Segment.changeset(attrs)
        {:error, changeset}
    end

  end

  @doc """
  Updates a segment.
  ## Examples
      iex> update_segment(segment, %{field: new_value}, tenant)
      {:ok, %Segment{}}
      iex> update_segment(segment, %{field: bad_value}, tenant)
      {:error, %Ecto.Changeset{}}
  """
  def update_segment(%Segment{} = segment, attrs, tenant) do

    attrs =
      attrs
      |> Map.put("date", segment.log.date)

    case add_utc_to_attrs(attrs, tenant) do
      {:ok, attrs} ->
        segment
        |> Segment.changeset(attrs)
        |> Repo.update()
      {:error, _message} ->
        changeset =
          segment
          |> Segment.changeset(attrs)
        {:error, changeset}
    end

  end

  def update_segment_utc(%Segment{} = segment, tenant) do

    date = Date.to_string(segment.log.date)

    if segment.start_time != nil and segment.end_time != nil do

      start_time = Time.to_string(segment.start_time)
      end_time = Time.to_string(segment.end_time)

      {:ok, start_datetime, end_datetime} = add_utc(date, start_time, end_time, tenant)
      attrs = %{start_datetime: start_datetime, end_datetime: end_datetime }

      _updated = segment
      |> Segment.changeset(attrs)
      |> Repo.update()

    end
  end
  @doc """
  Deletes a segment.

  ## Examples

      iex> delete_segment(segment)
      {:ok, %Segment{}}

      iex> delete_segment(segment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_segment(%Segment{} = segment) do
    Repo.delete(segment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking segment changes.

  ## Examples

      iex> change_segment(segment)
      %Ecto.Changeset{data: %Segment{}}

  """
  def change_segment(%Segment{} = segment, attrs \\ %{}) do
    Segment.changeset(segment, attrs)
  end

  @doc """
  Creates a playout_segment.

  ## Examples

      iex> create_playout_segment(%{field: value})
      {:ok, %Segment{}}

      iex> create_playout_segment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_playout_segment(attrs \\ %{}, tenant) do

    %PlayoutSegment{}
    |> PlayoutSegment.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Returns the list of playout_segments.
  ## Examples
      iex> list_playout_segments()
      [%PlayoutSegment{}, ...]
  """

  def list_playout_segments(tenant) do

    from(p in PlayoutSegment, order_by: [desc: :inserted_at])
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload([:category])
  end

  def list_full_playout_segments(params, tenant) do
    #%{timezone: timezone} = Admin.get_timezone!(tenant)
    late_time = "11:59:59"
    early_time = "00:00:00"
    {:ok, start_datetime, _some_datetime} = add_utc(params.start_date, early_time, late_time, tenant)
    {:ok,  _some_datetime, end_datetime} = add_utc(params.end_date, early_time, late_time, tenant)

    from(s in PlayoutSegment,
      where: s.inserted_at >= ^start_datetime,
      where: s.inserted_at <= ^end_datetime,
      order_by: [desc: s.inserted_at]
      
    )
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(category: [])
  end


  @doc """
  Returns a list of playout segments matching the given `filter`.

  Example filter:

  %{sources: ["ACR Cloud", "Studio 1"]}
  """

  def list_playout_segments_by_log_and_filter(filter, log, tenant) when is_map(filter) do
    from(p in PlayoutSegment,
    where: p.inserted_at >= ^log.start_datetime,
    where: p.inserted_at <= ^log.end_datetime,
    order_by: [desc: p.inserted_at]
    )
    |> filter_by_sources(filter)
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload([:category])
  end

  # defp filter_by_sources(query, %{sources: [""]}), do: query

  defp filter_by_sources(query, %{sources: sources}) do



    # case Enum.find(sources, fn source -> source == "on" end) do
    #   "on" ->

    #     where(query, [playout_segment], playout_segment.source in ^sources)
    #     |> where(query, [playout_segment], is_nil(playout_segment.source))

    #   nil ->
        where(query, [playout_segment], playout_segment.source in ^sources)

    # end
  end

  def list_distinct_sources(log, tenant) do
    from(ps in PlayoutSegment,
      select: ps.source,
      order_by: [desc: :inserted_at],
      distinct: ps.source,
      where: not is_nil(ps.source), 
      where: ps.inserted_at >= ^log.start_datetime,
      where: ps.inserted_at <= ^log.end_datetime
      )
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
  end
  @doc """
  Gets a single playout_segment.

  Raises `Ecto.NoResultsError` if the PlayoutSegment does not exist.

  ## Examples

      iex> get_playoutsegment!(123)
      %PlayoutSegment{}

      iex> get_playout_segment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_playout_segment!(id, tenant) do
    PlayoutSegment
    |> Repo.get!(id, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload([:category])
  end

  @doc """
  Updates a playout_segment.

  ## Examples

      iex> update_playout_segment(playout_segment, %{field: new_value})
      {:ok, %PlayoutSegment{}}

      iex> update_playout_segment(playout_segment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_playout_segment(%PlayoutSegment{} = playout_segment, attrs) do
    playout_segment
    |> PlayoutSegment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a playout_segment.

  ## Examples

      iex> delete_playout_segment(playout_segment)
      {:ok, %PlayoutSegment{}}

      iex> delete_playout_segment(playout_segment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_playout_segment(%PlayoutSegment{} = playout_segment) do
    Repo.delete(playout_segment)
  end

  def delete_all_playout_segments(tenant) do
    prefix = Triplex.to_prefix(tenant)

    Repo.delete_all(Radioapp.Station.PlayoutSegment, prefix: prefix)
  end

    @doc """
  Returns an `%Ecto.Changeset{}` for tracking playout_segment changes.

  ## Examples

      iex> change_playout_segment(playout_segment)
      %Ecto.Changeset{data: %PlayoutSegment{}}

  """
  def change_playout_segment(%PlayoutSegment{} = playout_segment, attrs \\ %{}) do
    PlayoutSegment.changeset(playout_segment, attrs)
  end


  @doc """
  Returns the list of images.
  ## Examples
      iex> list_images()
      [%Image{}, ...]
  """
  def list_images(tenant) do
    Image
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:program)
  end

  @doc """
  Gets a single image.
  Raises `Ecto.NoResultsError` if the Image does not exist.
  ## Examples
      iex> get_image!(123)
      %Image{}
      iex> get_image!(456)
      ** (Ecto.NoResultsError)
  """
  def get_image!(id, tenant) do
    Image
    |> Repo.get!(id, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:program)
  end

  @doc """
  Creates a image.
  ## Examples
      iex> create_image(%{field: value})
      {:ok, %Image{}}
      iex> create_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_image(attrs \\ %{}, tenant) do
    %Image{}
    |> Image.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  def create_image_from_plug_upload(%Program{} = program, %Plug.Upload{} = upload, tenant) do

    uuid = Ecto.UUID.generate()
    remote_path = "radioapp/#{tenant}/#{uuid}-#{upload.filename}"

    with {:ok, uploaded_image} <- send_upload_to_s3(remote_path, upload) do
      program
      |> Ecto.build_assoc(:images)
      |> Image.changeset(uploaded_image)
      |> Repo.insert(prefix: Triplex.to_prefix(tenant))
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  def download_from_s3(filename) do
    s3_bucket = "nvradio"

    resp =
      ExAws.S3.get_object(s3_bucket, filename)
      |> ExAws.request!(region: "ca-central-1")

    resp.body
  end

  def update_image_from_plug(%Image{} = image, %Plug.Upload{} = upload, tenant) do
    uuid = Ecto.UUID.generate()
    remote_path = "radioapp/#{tenant}/#{uuid}-#{upload.filename}"

    with {:ok, uploaded_image} <- send_upload_to_s3(remote_path, upload) do
      image
      |> Image.changeset(uploaded_image)
      |> Repo.update()
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp send_upload_to_s3(
         s3_filename,
         %{
           path: path,
           filename: filename,
           content_type: content_type
         }
       )
       when is_binary(path) and is_binary(filename) and is_binary(content_type) do
    hash =
      File.stream!(path, [], 2048)
      |> Image.sha256()

    with {:ok, %File.Stat{size: size}} <- File.stat(path),
         {:ok, %{status_code: 200}} <- upload_file_to_s3(path, s3_filename) do
      image_attrs = %{
        filename: filename,
        remote_filename: s3_filename,
        content_type: content_type,
        hash: hash,
        size: size
      }

      {:ok, image_attrs}
    else
      {:ok, %{status_code: code}} ->
        {:error, "Failed to upload image: #{code}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp send_upload_to_s3(_s3_filename, upload) do
    {:error, "Invalid upload: #{inspect(upload)}"}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking image changes.
  ## Examples
      iex> change_image(image)
      %Ecto.Changeset{source: %Image{}}
  """
  def change_image(%Image{} = image) do
    Image.changeset(image, %{})
  end

  def upload_file_to_s3(tmp_path, s3_filename) do
    s3_bucket = "nvradio"
    file_binary = File.read!(tmp_path)

    ExAws.S3.put_object(s3_bucket, s3_filename, file_binary)
    |> ExAws.request(region: "ca-central-1")
  end

  @doc """
  Deletes a image.
  ## Examples
      iex> delete_image(image)
      {:ok, %Image{}}
      iex> delete_image(image)
      {:error, %Ecto.Changeset{}}
  """
  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end
end
