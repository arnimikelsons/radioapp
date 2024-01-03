defmodule Radioapp.Repo.Migrations.UpdateSegmentsTable do
  use Ecto.Migration

  def change do
    alter table(:segments) do
      add :indigenous_artist, :boolean, default: false, null: false
      add :emerging_artist, :boolean, default: false, null: false
    end
  end
end
