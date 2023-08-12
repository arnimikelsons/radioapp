defmodule Radioapp.Station.Image do
  use Ecto.Schema
  import Ecto.Changeset

  alias Radioapp.Station.Program

  schema "images" do
    field :content_type, :string
    field :filename, :string
    field :hash, :string
    field :size, :integer
    field :remote_filename, :string
    belongs_to :program, Program

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:filename, :size, :content_type, :hash, :remote_filename])
    |> validate_required([:filename, :size, :content_type, :hash, :remote_filename])
    # added validations
    |> validate_number(:size, greater_than: 0)
    |> validate_length(:hash, is: 64)
  end

  def sha256(chunks_enum) do
    chunks_enum
    |> Enum.reduce(
      :crypto.hash_init(:sha256),
      &:crypto.hash_update(&2, &1)
    )
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

  def upload_directory do
    Application.fetch_env!(:id, :uploads_directory)
  end

  def local_path(id, filename) do
    [upload_directory(), "#{id}-#{filename}"]
    |> Path.join()
  end
end
