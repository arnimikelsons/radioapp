defmodule Radioapp.Repo.Migrations.UpdateSegmentsAddArtist do
  use Ecto.Migration

  def change do
    alter table(:segments) do
      add :artist, :string
    end
  end
end
