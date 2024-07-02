defmodule Radioapp.Repo.Migrations.AddWelcomeEmailToSystemDefaults do
  use Ecto.Migration

  def change do
    alter table(:stationdefaults) do
      add :intro_email_subject, :string
      add :intro_email_body, :text
      add :api_permission, :string, default: "none"
    end

  end
end
