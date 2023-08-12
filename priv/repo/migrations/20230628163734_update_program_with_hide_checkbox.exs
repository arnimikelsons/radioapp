defmodule Radioapp.Repo.Migrations.UpdateProgramWithHideCheckbox do
  use Ecto.Migration

  def change do
    alter table(:programs) do
      add :hide, :boolean
      remove :show_archive
    end

  end
end
