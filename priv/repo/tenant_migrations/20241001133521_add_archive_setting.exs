defmodule Radioapp.Repo.Migrations.AddArchiveSetting do
  use Ecto.Migration

  def change do
    alter table(:stationdefaults) do
      add :enable_archives, :string, default: "none"
    end
  end
end
