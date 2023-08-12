defmodule Radioapp.Repo.Migrations.UpdateProgramsTable do
  use Ecto.Migration

  def change do
    alter table(:programs) do
      add :short_description, :string
    end
  end
end
