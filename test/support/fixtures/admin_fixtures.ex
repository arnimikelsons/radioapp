defmodule Radioapp.AdminFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Radioapp.Admin` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        code: "some code",
        name: "some name"
      })
      |> Radioapp.Admin.create_category()

    category
  end

  @doc """
  Generate a stationdefaults.
  """
  def stationdefaults_fixture(attrs \\ %{}) do
    {:ok, stationdefaults} =
      attrs
      |> Enum.into(%{
        callsign: "some callsign",
        from_email: "some from_email",
        from_email_name: "some from_email_name",
        logo_path: "some logo_path",
        org_name: "some org_name",
        phone: "some phone",
        playout_url: "some playout_url",
        privacy_policy_url: "some privacy_policy_url",
        support_email: "some support_email",
        tos_url: "some tos_url",
        website_url: "some website_url"
      })
      |> Radioapp.Admin.create_stationdefaults()

    stationdefaults
  end
end
