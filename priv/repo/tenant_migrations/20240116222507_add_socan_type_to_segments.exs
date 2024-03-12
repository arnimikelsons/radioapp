defmodule Radioapp.Repo.Migrations.AddSocanTypeToSegments do
  use Ecto.Migration

  def change do
    alter table(:segments) do
      add :socan_type, :string
    end
  end
end
