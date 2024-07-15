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
    field :start_datetime, :utc_datetime
    field :end_datetime, :utc_datetime

    belongs_to :program, Program
    has_many :segments, Segment

    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:host_name, :notes, :category, :date, :end_time, :language, :start_time, :start_datetime, :end_datetime])
    |> validate_required([:host_name, :category, :date, :end_time, :start_time])
  end

end
