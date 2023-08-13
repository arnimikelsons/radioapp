defmodule Radioapp.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs) do
      add :host_name, :string
      add :date, :date
      add :start_time, :time
      add :end_time, :time
      add :category, :string
      add :language, :string
      add :notes, :text
      
      add :program_id, references(:programs, on_delete: :nothing)

      timestamps()
    end

    create index(:logs, [:program_id])
  end
end
