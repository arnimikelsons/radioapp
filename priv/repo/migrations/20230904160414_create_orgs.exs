defmodule Radioapp.Repo.Migrations.CreateOrgs do
  use Ecto.Migration

  def change do
    create table(:orgs) do
      add :address1, :string
      add :address2, :string
      add :city, :string
      add :country, :string
      add :email, :string
      add :full_name, :string
      add :short_name, :string
      add :organization, :string
      add :postal_code, :string
      add :province, :string
      add :telephone, :string
      add :tenant_name, :string

      timestamps()
    end
  end
end
