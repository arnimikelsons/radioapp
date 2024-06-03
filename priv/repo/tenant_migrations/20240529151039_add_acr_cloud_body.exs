defmodule Radioapp.Repo.Migrations.AddAcrCloudBody do
  use Ecto.Migration

  def change do
    alter table(:playout_segments) do
      add(:body, :string)
    end
  end
end
