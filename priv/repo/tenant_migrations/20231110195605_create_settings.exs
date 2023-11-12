defmodule Radioapp.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :callsign, :string
      add :from_email, :string
      add :from_email_name, :string
      add :logo_path, :string
      add :org_name, :string
      add :privacy_policy_url, :string
      add :support_email, :string
      add :phone, :string
      add :playout_url, :string
      add :playout_type, :string
      add :tos_url, :string
      add :website_url, :string

      timestamps()
    end
  end
end
