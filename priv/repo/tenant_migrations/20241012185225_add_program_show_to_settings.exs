defmodule Radioapp.Repo.Migrations.AddProgramShowToSettings do
  use Ecto.Migration

  def change do
    alter table(:stationdefaults) do
      add :program_show, :string, default: "all"
    end
  end
end
