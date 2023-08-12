defmodule Radioapp.Repo.Migrations.CreatePrograms do
  use Ecto.Migration

  def change do
    create table(:programs) do
      add :name, :string
      add :description, :string
      add :genre, :string

      timestamps()
    end
  end
end
