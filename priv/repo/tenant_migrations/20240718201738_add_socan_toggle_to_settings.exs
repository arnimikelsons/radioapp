defmodule Radioapp.Repo.Migrations.AddSocanToggleToSettings do
  use Ecto.Migration

  def change do
    alter table(:stationdefaults) do
      add :socan_permission, :string, default: "none"
    end
  end
end
