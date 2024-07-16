defmodule Radioapp.Repo.Migrations.AddSourceToPlayoutSegments do
  use Ecto.Migration

  def change do
    alter table(:playout_segments) do
      add(:source, :string)
    end
  end
end
