defmodule Radioapp.Station.Log do
  use Ecto.Schema
  import Ecto.Changeset

  alias Radioapp.Station.{Program, Segment}

  schema "logs" do
    field :host_name, :string
    field :notes, :string
    field :category, :string
    field :date, :date
    field :end_time, :time
    field :language, :string, default: "English"
    field :start_time, :time
    field :start_datetime, :naive_datetime
    field :end_datetime, :naive_datetime

    belongs_to :program, Program
    has_many :segments, Segment

    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:host_name, :notes, :category, :date, :end_time, :language, :start_time, :start_datetime, :end_datetime])
    # |> add_datetimes()
    |> validate_required([:host_name, :category, :date, :end_time, :start_time])
  end

  # def add_start_datetime(changeset) do
  #   case changeset do
  #     %{changes: %{date: date, start_time: start_time}, errors: []} ->

  #       # OVERVIEW: Calculate based on utc and insert naive_datetime in both datetime fields
  #       # 1. Create a naive_datetime value from date and start_time
  #       {:ok, start_datetime} = NaiveDateTime.new(date, start_time)
  #       {:ok, end_datetime} = NaiveDateTime.new(date, end_time)

  #       # 2. Convert that value to utc datetime value using the stationdefaults timezone
  #       dbg(start_datetime)
  #       # 3. insert into field with no associated timezone

  #       # 4. update changeset with two new values
  #       changeset
  #       |> put_change(:end_datetime, end_datetime)
  #       |> put_change(:start_datetime, start_datetime)

  #     %{} ->
  #       changeset
  #   end
  # end

  # def add_end_datetime(changeset) do
  #   case changeset do
  #     %{changes: %{date: date, start_time: start_time, end_time: end_time}, errors: []} ->

  #       # OVERVIEW: Calculate based on utc and insert naive_datetime in both datetime fields
  #       # 1. Create a naive_datetime value from date and start_time
  #       {:ok, start_datetime} = NaiveDateTime.new(date, start_time)
  #       {:ok, end_datetime} = NaiveDateTime.new(date, end_time)

  #       # 2. Convert that value to utc datetime value using the stationdefaults timezone
  #       dbg(start_datetime)
  #       # 3. insert into field with no associated timezone

  #       # 4. update changeset with two new values
  #       changeset
  #       |> put_change(:end_datetime, end_datetime)
  #       |> put_change(:start_datetime, start_datetime)

  #     %{} ->
  #       changeset
  #   end
  # end


end
