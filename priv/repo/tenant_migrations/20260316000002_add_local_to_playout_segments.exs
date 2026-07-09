defmodule Radioapp.Repo.Migrations.AddLocalToPlayoutSegments do
  use Ecto.Migration

  def change do
    alter table(:playout_segments) do
      add :local, :boolean, default: false, null: false
    end
  end
end
