defmodule Radioapp.AdminTest do
  use Radioapp.DataCase
  alias Radioapp.Factory
  alias Radioapp.Admin.{Category, Link}
  alias Radioapp.Admin

  @tenant "sample"

  describe "links" do
    @invalid_attrs %{icon: nil, type: nil, url: nil}

    test "list_links/0 returns all links" do
      link = Factory.insert(:link)
      assert Admin.list_links(@tenant) == [link]
    end

    test "get_link!/1 returns the link with given id" do
      link = Factory.insert(:link)
      assert Admin.get_link!(link.id) == link
    end

    test "create_link/1 with valid data creates a link" do
      valid_attrs = %{icon: "some icon", type: "some type"}

      assert {:ok, %Link{} = link} = Admin.create_link(valid_attrs)
      assert link.icon == "some icon"
      assert link.type == "some type"
    end

    #no invalid attrs
    #test "create_link/1 with invalid data returns error changeset" do
    #  assert {:error, %Ecto.Changeset{}} = Admin.create_link(@invalid_attrs)
    #end

    test "update_link/2 with valid data updates the link" do
      link = Factory.insert(:link)
      update_attrs = %{icon: "some updated icon", type: "some updated type"}

      assert {:ok, %Link{} = link} = Admin.update_link(link, update_attrs)
      assert link.icon == "some updated icon"
      assert link.type == "some updated type"
    end

    #no invalid attrs
    #test "update_link/2 with invalid data returns error changeset" do
    #  link = link_fixture()
    #  assert {:error, %Ecto.Changeset{}} = Admin.update_link(link, @invalid_attrs)
    #  assert link == Admin.get_link!(link.id)
    #end

    test "delete_link/1 deletes the link" do
      link = Factory.insert(:link)
      assert {:ok, %Link{}} = Admin.delete_link(link)
      assert_raise Ecto.NoResultsError, fn -> Admin.get_link!(link.id) end
    end

    test "change_link/1 returns a link changeset" do
      link = Factory.insert(:link)
      assert %Ecto.Changeset{} = Admin.change_link(link)
    end
  end

  describe "categories" do
    @invalid_attrs %{code: nil, name: nil}

    test "list_categories/0 returns all categories" do
      category = Factory.insert(:category)
      assert Admin.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = Factory.insert(:category)
      assert Admin.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{code: "some code", name: "some name"}

      assert {:ok, %Category{} = category} = Admin.create_category(valid_attrs)
      assert category.code == "some code"
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Admin.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = Factory.insert(:category)
      update_attrs = %{code: "some updated code", name: "some updated name"}

      assert {:ok, %Category{} = category} = Admin.update_category(category, update_attrs)
      assert category.code == "some updated code"
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = Factory.insert(:category)
      assert {:error, %Ecto.Changeset{}} = Admin.update_category(category, @invalid_attrs)
      assert category == Admin.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = Factory.insert(:category)
      assert {:ok, %Category{}} = Admin.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Admin.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = Factory.insert(:category)
      assert %Ecto.Changeset{} = Admin.change_category(category)
    end
  end
end
