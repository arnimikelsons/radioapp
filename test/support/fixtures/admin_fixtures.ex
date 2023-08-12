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
end
