defmodule Radioapp.Station.Program do
  use Ecto.Schema
  import Ecto.Changeset
  alias Radioapp.Station.{Timeslot, Log, Image}
  alias Radioapp.Admin.Link

  schema "programs" do
    field :description, :string
    field :genre, :string
    field :name, :string
    field :short_description, :string
    field :hide, :boolean, default: false
    field :link1_url, :string
    field :link2_url, :string
    field :link3_url, :string

    has_many :timeslots, Timeslot
    has_one :images, Image
    belongs_to :link1, Link
    belongs_to :link2, Link
    belongs_to :link3, Link
    has_many :logs, Log

    timestamps()
  end

  @doc false
  def changeset(program, attrs) do
    program
    |> cast(attrs, [:name, :description, :genre, :short_description, :hide, :link1_url, :link2_url, :link3_url, :link1_id, :link2_id, :link3_id])
    |> validate_required([:name, :description, :genre, :short_description])
  end
end
