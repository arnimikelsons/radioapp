defmodule Radioapp.Repo.Migrations.CreateTimeslots do
  use Ecto.Migration

  def change do
    create table(:timeslots) do
      add :day, :integer
      add :starttime, :time
      add :runtime, :integer
      add :endtime, :time
      add :starttimereadable, :string
      add :program_id, references(:programs, on_delete: :delete_all)

      timestamps()
    end

    create index(:timeslots, [:program_id])
  end
end
