defmodule Radioapp.Repo.Migrations.UpdateAddArchiveWeeks do
  use Ecto.Migration

  def change do
    alter table(:stationdefaults) do
      add :weeks_of_archives, :integer
    end
  end
end
