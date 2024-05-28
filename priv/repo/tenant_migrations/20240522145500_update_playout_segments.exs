defmodule Radioapp.Repo.Migrations.UpdatePlayoutSegments do
  use Ecto.Migration

  def change do
    alter table(:playout_segments) do
      add(:category_id, references("categories"))
    end
  end
end
