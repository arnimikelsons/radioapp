defmodule Radioapp.Repo.Migrations.ConvertTimestampsToUtc do
  use Ecto.Migration

  def change do
    alter table(:playout_segments) do
      modify :inserted_at, :utc_datetime
      modify :updated_at, :utc_datetime
    end
  end
end
