defmodule Radioapp.Repo.Migrations.DatetimeForLogsSegments do
  use Ecto.Migration

  def change do
    alter table(:segments) do
      add(:start_datetime, :naive_datetime)
      add(:end_datetime, :naive_datetime)
    end
    alter table(:logs) do
      add(:start_datetime, :naive_datetime)
      add(:end_datetime, :naive_datetime)
    end
  end
end
