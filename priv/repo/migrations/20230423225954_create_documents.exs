defmodule Radioapp.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add(:filename, :string)
      add(:size, :bigint)
      add(:content_type, :string)
      add(:hash, :string, size: 64)
      add(:program_id, references(:programs, on_delete: :delete_all))
      add(:remote_filename, :string)
      timestamps()
    end

    create(index(:images, [:program_id]))
    create(index(:images, [:hash]))
  end
end