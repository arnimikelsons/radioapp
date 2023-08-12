defmodule Radioapp.Station.Timeslot do
  use Ecto.Schema
  use Timex
  import Ecto.Changeset

  alias Radioapp.Station.Program

  schema "timeslots" do
    field :day, :integer
    field :endtime, :time
    field :runtime, :integer
    field :starttime, :time
    field :starttimereadable, :string

    belongs_to :program, Program

    timestamps()
  end

  @doc false
  def changeset(timeslot, attrs) do
    changeset =
      timeslot
      |> cast(attrs, [:day, :starttime, :runtime, :endtime, :starttimereadable])
      |> validate_required([:day, :starttime, :runtime])

    starttime = get_field(changeset, :starttime)
    runtime = get_field(changeset, :runtime)

    case {starttime, runtime} do
      {%Time{} = t, runtime} when is_integer(runtime) ->
        endtime = Time.add(t, runtime, :minute)

        starttimereadable =
          NaiveDateTime.from_erl!({{2000, 1, 1}, Time.to_erl(Time.truncate(starttime, :second))})
          |> Timex.format!("{h12}:{0m} {am}")

        changeset
        |> put_change(:endtime, endtime)
        |> put_change(:starttimereadable, starttimereadable)

      _ ->
        changeset
    end
  end
end
