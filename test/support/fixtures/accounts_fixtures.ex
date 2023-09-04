defmodule Radioapp.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Radioapp.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      full_name: "Some Full Name",
      short_name: "Some Short Name",
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Radioapp.Accounts.register_user()
    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  @doc """
  Generate a org.
  """
  def org_fixture(attrs \\ %{}) do
    {:ok, org} =
      attrs
      |> Enum.into(%{
        address1: "some address1",
        address2: "some address2",
        city: "some city",
        country: "some country",
        email: "some email",
        full_name: "some full_name",
        organization: "some organization",
        postal_code: "some postal_code",
        province: "some province",
        short_name: "some short_name",
        telephone: "some telephone",
        tenant_name: "some tenant_name"
      })
      |> Radioapp.Accounts.create_org()

    org
  end
end
