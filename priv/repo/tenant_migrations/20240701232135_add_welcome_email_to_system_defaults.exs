defmodule Radioapp.Repo.Migrations.AddWelcomeEmailToSystemDefaults do
  use Ecto.Migration

  def change do
    alter table(:stationdefaults) do
      add :intro_email_subject, :string, default: "Welcome to RadioApp: Website Management and Radio Logging Software"
      add :intro_email_body, :text, default: "You are invited to join the Radioapp online App to manage your radio program."
      add :api_permission, :string, default: "none"
    end

  end
end
