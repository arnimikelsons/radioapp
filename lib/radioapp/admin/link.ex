defmodule Radioapp.Admin.Link do
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :icon, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:type, :icon])
    |> validate_required([:type, :icon])
  end
end
