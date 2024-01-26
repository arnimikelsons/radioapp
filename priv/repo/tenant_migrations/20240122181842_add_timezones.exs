defmodule Radioapp.Repo.Migrations.AddTimezones do
  use Ecto.Migration

  def change do
    alter table(:stationdefaults) do
      add(:timezone, :string)
    end
  end
end
