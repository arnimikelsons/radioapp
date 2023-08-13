defmodule Radioapp.Repo.Migrations.AddIndexes do
  use Ecto.Migration

  def change do
    create(unique_index(:categories, [:code]))
    create(index(:categories, [:segments_id]))
    create(unique_index(:links, [:type]))
    create(index(:logs, [:date]))
    create(index(:programs, [:link1_id]))
    create(index(:programs, [:link2_id]))
    create(index(:programs, [:link3_id]))
    create(index(:programs, [:name]))
    create(index(:segments, [:start_time]))
    create(index(:timeslots, [:day]))
    create(index(:timeslots, [:day, :starttime]))
    create(index(:timeslots, [:starttime]))    
  end
end
