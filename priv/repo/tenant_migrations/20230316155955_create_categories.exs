defmodule Radioapp.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :code, :string
      add :name, :string

      add(:segments_id, references("segments"))
      timestamps()
    end

    alter table(:segments) do
      add(:category_id, references("categories"))
    end
  end
end
