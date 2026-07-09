defmodule Radioapp.Repo.Migrations.AddLocalToSegments do
  use Ecto.Migration

  def change do
    alter table(:segments) do
      add :local, :boolean, default: false, null: false
    end
  end
end
