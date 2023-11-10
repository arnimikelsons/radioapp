defmodule Radioapp.Admin.Settings do
  use Ecto.Schema
  import Ecto.Changeset

  schema "settings" do
    field :callsign, :string
    field :from_email, :string
    field :from_email_name, :string
    field :logo_path, :string
    field :org_name, :string
    field :phone, :string
    field :playout_url, :string
    field :privacy_policy_url, :string
    field :support_email, :string
    field :tos_url, :string
    field :website_url, :string

    timestamps()
  end

  @doc false
  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:callsign, :from_email, :from_email_name, :logo_path, :org_name, :privacy_policy_url, :support_email, :phone, :playout_url, :tos_url, :website_url])
    |> validate_required([:callsign, #:from_email, :from_email_name, :logo_path, :org_name, :privacy_policy_url, :support_email, :phone, :playout_url, :tos_url, :website_url
    ])
  end
end
