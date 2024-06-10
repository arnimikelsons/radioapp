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
    from(p in Program, order_by: [asc: :name])
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload([
      :timeslots,
      :images,
      :link1,
      :link2,
      :link3
    ])
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
    Program
    |> Repo.get!(id, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload([
      :timeslots,
      :images,
      :link1,
      :link2,
      :link3
    ])
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

  def list_logs_for_program(program, tenant) do
    from(l in Log, where: [program_id: ^program.id], order_by: [asc: :date])
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

      iex> create_log(%{field: value})
      {:ok, %Log{}}

      iex> create_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_log(%Program{} = program, attrs \\ %{}, tenant) do

    %{timezone: station_timezone} = Admin.get_timezone!(tenant)
    %{"date" => date, "start_time" => start_time, "end_time" => end_time }= attrs

     # Fix start time error missing seconds value
     start_time =
      case String.length(start_time) do
        5 ->
          start_time <> ":00"
        8 ->
          start_time
        _ ->
          nil
      end
     # Convert start_datetime to UTC
    {:ok, start_date_time_naive} = NaiveDateTime.from_iso8601("#{date} #{start_time}")
    {:ok, start_datetime} = DateTime.from_naive(start_date_time_naive, station_timezone)

    # Fix end time error missing seconds value
    end_time =
      case String.length(end_time) do
        5 ->
          end_time <> ":00"
        8 ->
          end_time
        _ ->
          nil
      end
    # Convert end_datetime to UTC
    {:ok, end_date_time_naive} = NaiveDateTime.from_iso8601("#{date} #{end_time}")
    {:ok, end_datetime} = DateTime.from_naive(end_date_time_naive, station_timezone)

    attrs =
      attrs
      |> Map.put("start_datetime", start_datetime)
      |> Map.put("end_datetime", end_datetime)

    program
    |> Ecto.build_assoc(:logs)
    |> Log.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Updates a log.

  ## Examples

      iex> update_log(log, %{field: new_value})
      {:ok, %Log{}}

      iex> update_log(log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_log(%Log{} = log, attrs) do
    log
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
  Returns the list of segments.

  ## Examples

      iex> list_segments()
      [%Segment{}, ...]

  """
  def list_segments(tenant) do
    Repo.all(Segment, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload([:category, log: [:program]])
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
        program_name: p.name,
        host_name: l.host_name,
        log_category: l.category,
        date: l.date,
        log_start_time: l.start_time,
        log_end_time: l.end_time,
        language: l.language,
        start_time: s.start_time,
        end_time: s.end_time,
        category: [c.code, "-", c.name],
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

    log
    |> Ecto.build_assoc(:segments)
    |> Segment.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  def create_segment_relaxed(%Log{} = log, attrs \\ %{}, tenant) do

    log
    |> Ecto.build_assoc(:segments)
    |> Segment.changeset_relaxed(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Updates a segment.

  ## Examples

      iex> update_segment(segment, %{field: new_value})
      {:ok, %Segment{}}

      iex> update_segment(segment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_segment(%Segment{} = segment, attrs) do
    segment
    |> Segment.changeset(attrs)
    |> Repo.update()
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
