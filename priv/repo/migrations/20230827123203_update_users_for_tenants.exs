defmodule Radioapp.Repo.Migrations.UpdateUsersForTenants do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :roles, :map, null: false, default: %{}
      add :terms_date, :utc_datetime, null: true
    end
  end
end
