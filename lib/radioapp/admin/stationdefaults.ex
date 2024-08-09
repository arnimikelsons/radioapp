defmodule Radioapp.Admin.Stationdefaults do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stationdefaults" do
    field :callsign, :string
    field :from_email, :string
    field :from_email_name, :string
    field :logo_path, :string
    field :org_name, :string
    field :timezone, :string
    field :phone, :string
    field :playout_url, :string
    field :playout_type, :string
    field :privacy_policy_url, :string
    field :support_email, :string
    field :tos_url, :string
    field :website_url, :string
    field :csv_permission, :string, default: "none"
    field :intro_email_subject, :string
    field :intro_email_body, :string
    field :api_permission, :string, default: "none"
    field :socan_permission, :string, default: "none"    
    field :export_log_permission, :string, default: "none"    

    timestamps()
  end

  @doc false
  def changeset(stationdefaults, attrs) do
    stationdefaults
    |> cast(attrs, [:callsign, :from_email, :from_email_name, :logo_path, :org_name, :timezone, :privacy_policy_url, :support_email, :phone, :playout_url, :playout_type, :tos_url, :website_url, :csv_permission, :intro_email_subject, :intro_email_body, :api_permission, :socan_permission, :export_log_permission])
    |> validate_required([:callsign, :timezone, :support_email #, :from_email, :from_email_name, :logo_path, :org_name, :privacy_policy_url, :phone, :playout_url, :playout_type, :tos_url, :website_url, :csv_permission, :intro_email_subject, :intro_email_body
    ])
  end
end
