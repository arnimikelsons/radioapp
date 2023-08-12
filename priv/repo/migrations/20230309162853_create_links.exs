defmodule Radioapp.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :type, :string
      add :icon, :string

      add(:program_id, references("programs", on_delete: :delete_all))

      timestamps()
    end

    create index(:links, [:program_id])

    alter table(:programs) do
      modify :description, :text
      add :show_archive, :boolean
      add :link1_id, references("links", on_delete: :delete_all)
      add :link1_url, :string
      add :link2_id, references("links", on_delete: :delete_all)
      add :link2_url, :string
      add :link3_id, references("links", on_delete: :delete_all)
      add :link3_url, :string
    end
  end
end
