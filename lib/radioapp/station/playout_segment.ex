defmodule Radioapp.Station.PlayoutSegment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Radioapp.Admin.Category

  schema "playout_segments" do
    field :artist, :string
    field :can_con, :boolean, default: false
    field :catalogue_number, :string
    field :emerging_artist, :boolean, default: false
    field :end_time, :time
    field :hit, :boolean, default: false
    field :indigenous_artist, :boolean, default: false
    field :instrumental, :boolean, default: false
    field :new_music, :boolean, default: false
    field :socan_type, :string
    field :song_title, :string
    field :start_time, :time
    field :duration, :string, virtual: true
    field :body, :string


    belongs_to :category, Category

    timestamps([type: :utc_datetime])
  end

  @doc false
  def changeset(playout_segment, attrs) do
    playout_segment
    |> cast(attrs, [:artist, :can_con, :catalogue_number, :end_time, :hit, :instrumental, :new_music, :indigenous_artist, :emerging_artist, :start_time, :socan_type, :song_title, :category_id, :duration, :body])
    |> normalize_duration()
    |> validate_required([:artist, :song_title])
  end


  def change_end_time(changeset) do
    start_time = get_field(changeset, :start_time)
    duration = get_field(changeset, :duration) || 0

    changeset
    |> put_change(:end_time, Time.add(start_time, duration, :second))
  end

  def change_duration(changeset) do
    start_time = get_field(changeset, :start_time)
    end_time = get_field(changeset, :end_time)

    changeset
    |> put_change(:duration, Time.diff(end_time, start_time))
  end

  @hours_and_minutes ~r/((?<h>\d+h)*(?<m>\d+m)*(?<s>\d+s)*)+/
  defp normalize_duration(changeset) do
    if duration = get_change(changeset, :duration) do
      case Regex.scan(@hours_and_minutes, duration, capture: :all_names) do
        [["", "", ""], _] ->
          parse_unformatted(changeset, duration)

        [[h, m, s], _] ->
          hours = convert(h, "h")
          minutes = convert(m, "m")
          seconds = convert(s, "s")
          duration = hours * 60 * 60 + minutes * 60 + seconds
          put_change(changeset, :duration, duration)

        _ ->
          parse_unformatted(changeset, duration)
      end
    else
      changeset
    end
  end

  defp convert(input_string, unit) do
    case String.split(input_string, unit) do
      [""] -> 0
      [str, ""] -> String.to_integer(str)
    end
  end

  defp parse_unformatted(changeset, duration) do
    case Integer.parse(duration, 10) do
      {duration, ""} ->
        put_change(changeset, :duration, duration)

      _ ->
        delete_change(changeset, :duration)
    end
  end
end
