defmodule Radioapp.Repo.Migrations.LogExportPermission do
  use Ecto.Migration

  def change do
    alter table(:stationdefaults) do
      add :export_log_permission, :string, default: "none"
    end
  end
end
