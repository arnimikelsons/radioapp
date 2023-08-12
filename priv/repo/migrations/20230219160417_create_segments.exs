defmodule Radioapp.Repo.Migrations.CreateSegments do
  use Ecto.Migration

  def change do
    create table(:segments) do
      add :start_time, :time
      add :end_time, :time
      add :song_title, :string
      add :catalogue_number, :string
      add :new_music, :boolean, default: false, null: false
      add :instrumental, :boolean, default: false, null: false
      add :hit, :boolean, default: false, null: false
      add :can_con, :boolean, default: false, null: false
      add :log_id, references(:logs, on_delete: :nothing)


      timestamps()
    end

    create index(:segments, [:log_id])
  end
end
