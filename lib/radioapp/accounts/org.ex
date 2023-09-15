defmodule Radioapp.Accounts.Org do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orgs" do
    field :address1, :string
    field :address2, :string
    field :city, :string
    field :country, :string
    field :email, :string
    field :full_name, :string
    field :organization, :string
    field :postal_code, :string
    field :province, :string
    field :short_name, :string
    field :telephone, :string
    field :tenant_name, :string

    timestamps()
  end

  @doc false
  def changeset(org, attrs) do
    org
    |> cast(attrs, [:address1, :address2, :city, :country, :email, :full_name, :short_name, :organization, :postal_code, :province, :telephone, :tenant_name])
    |> validate_required([:city, :country, :email, :full_name, :short_name, :organization, :postal_code, :province, :telephone, :tenant_name])
    |> unique_constraint(:tenant_name)
  end
end
