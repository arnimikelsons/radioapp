defmodule Radioapp.Repo.Migrations.UpdatePostsStationdefaultsWithCsvPermission do
  use Ecto.Migration

  def change do
    alter table(:stationdefaults) do
      add :csv_permission, :string, default: "none"
    end
  end
end
