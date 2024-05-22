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

    belongs_to :category, Category

    timestamps()
  end

  @doc false
  def changeset(playout_segment, attrs) do
    playout_segment
    |> cast(attrs, [:artist, :can_con, :catalogue_number, :end_time, :hit, :instrumental, :new_music, :indigenous_artist, :emerging_artist, :start_time, :socan_type, :song_title, :category_id])
    |> validate_required([:artist, :start_time, :song_title])
  end
end
