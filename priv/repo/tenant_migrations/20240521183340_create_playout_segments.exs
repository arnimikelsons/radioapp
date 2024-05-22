defmodule Radioapp.Repo.Migrations.CreatePlayoutSegments do
  use Ecto.Migration

  def change do
    create table(:playout_segments) do
      add :artist, :string
      add :can_con, :boolean, default: false, null: false
      add :catalogue_number, :string
      add :end_time, :time
      add :hit, :boolean, default: false, null: false
      add :instrumental, :boolean, default: false, null: false
      add :new_music, :boolean, default: false, null: false
      add :indigenous_artist, :boolean, default: false, null: false
      add :emerging_artist, :boolean, default: false, null: false
      add :start_time, :time
      add :socan_type, :string
      add :song_title, :string

      timestamps()
    end
  end
end
