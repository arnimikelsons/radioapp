defmodule Radioapp.Admin.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias Radioapp.Station.Segment

  schema "categories" do
    field :code, :string
    field :name, :string

    has_many :segments, Segment

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
  end
end
