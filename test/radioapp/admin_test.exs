defmodule Radioapp.AdminTest do
  use Radioapp.DataCase
  alias Radioapp.Factory
  alias Radioapp.Admin.{Category, Link, Orgsettings}
  alias Radioapp.Admin

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  describe "links" do
    @valid_attrs %{icon: "some icon", type: "some type"}
    @update_attrs %{icon: "some updated icon", type: "some updated type"}
    @invalid_attrs %{icon: nil, type: nil, url: nil}

    test "list_links/0 returns all links" do
      link = Factory.insert(:link, [], prefix: @prefix)
      assert Admin.list_links(@tenant) == [link]
    end

    test "get_link!/1 returns the link with given id" do
      link = Factory.insert(:link, [], prefix: @prefix)
      assert Admin.get_link!(link.id, @tenant) == link
    end

    test "create_link/1 with valid data creates a link" do
      
      assert {:ok, %Link{} = link} = Admin.create_link(@valid_attrs, @tenant)
      assert link.icon == "some icon"
      assert link.type == "some type"
    end

    #no invalid attrs
    #test "create_link/1 with invalid data returns error changeset" do
    #  assert {:error, %Ecto.Changeset{}} = Admin.create_link(@invalid_attrs)
    #end

    test "update_link/2 with valid data updates the link" do
      link = Factory.insert(:link, [], prefix: @prefix)

      assert {:ok, %Link{} = link} = Admin.update_link(link, @update_attrs)
      assert link.icon == "some updated icon"
      assert link.type == "some updated type"
    end

    #no invalid attrs
    #test "update_link/2 with invalid data returns error changeset" do
    #  link = Factory.insert(:link, [], prefix: @prefix)
    #  assert {:error, %Ecto.Changeset{}} = Admin.update_link(link, @invalid_attrs)
    #  assert link == Admin.get_link!(link.id)
    #end

    test "delete_link/1 deletes the link" do
      link = Factory.insert(:link, [], prefix: @prefix)
      assert {:ok, %Link{}} = Admin.delete_link(link)
      assert_raise Ecto.NoResultsError, fn -> Admin.get_link!(link.id, @tenant) end
    end

    test "change_link/1 returns a link changeset" do
      link = Factory.insert(:link, [], prefix: @prefix)
      assert %Ecto.Changeset{} = Admin.change_link(link)
    end
  end

  describe "categories" do
    @valid_attrs %{code: "some code", name: "some name"}
    @update_attrs %{code: "some updated code", name: "some updated name"}
    @invalid_attrs %{code: nil, name: nil}

    test "list_categories/0 returns all categories" do
      category = Factory.insert(:category, [], prefix: @prefix)
      assert Admin.list_categories(@tenant) == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = Factory.insert(:category, [], prefix: @prefix)
      assert Admin.get_category!(category.id, @tenant) == category
    end

    test "create_category/1 with valid data creates a category" do
      assert {:ok, %Category{} = category} = Admin.create_category(@valid_attrs, @tenant)
      assert category.code == "some code"
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Admin.create_category(@invalid_attrs, @tenant)
    end

    test "update_category/2 with valid data updates the category" do
      category = Factory.insert(:category, [], prefix: @prefix)
      
      assert {:ok, %Category{} = category} = Admin.update_category(category, @update_attrs)
      assert category.code == "some updated code"
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = Factory.insert(:category, [], prefix: @prefix)
      assert {:error, %Ecto.Changeset{}} = Admin.update_category(category, @invalid_attrs)
      assert category == Admin.get_category!(category.id, @tenant)
    end

    test "delete_category/1 deletes the category" do
      category = Factory.insert(:category, [], prefix: @prefix)
      assert {:ok, %Category{}} = Admin.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Admin.get_category!(category.id, @tenant) end
    end

    test "change_category/1 returns a category changeset" do
      category = Factory.insert(:category, [], prefix: @prefix)
      assert %Ecto.Changeset{} = Admin.change_category(category)
    end
  end

#   describe "orgsettings" do
#     @valid_attrs %{from_email: "some from_email", from_email_name: "some from_email_name", org_name: "some org_name", support_email: "some support_email", tenant_name: "some tenant_name", url: "some url"}
#     @update_attrs %{from_email: "some updated from_email", from_email_name: "some updated from_email_name", org_name: "some updated org_name", support_email: "some updated support_email", tenant_name: "some updated tenant_name", url: "some updated url"}
#     @invalid_attrs %{from_email: nil, from_email_name: nil, org_name: nil, support_email: nil, tenant_name: nil, url: nil}

#     test "list_orgsettings/0 returns all orgsettings" do
#       orgsettings = Factory.insert(:orgsettings, [], prefix: @prefix)
#       assert Admin.list_orgsettings(@tenant) == [orgsettings]
#     end

#     test "get_orgsettings!/1 returns the orgsettings with given id" do
#       orgsettings = Factory.insert(:orgsettings, [], prefix: @prefix)
#       assert Admin.get_orgsettings!(orgsettings.id, @tenant) == orgsettings
#     end

#     test "create_orgsettings/1 with valid data creates a orgsettings" do
    
#       assert {:ok, %Orgsettings{} = orgsettings} = Admin.create_orgsettings(@valid_attrs, @tenant)
#       assert orgsettings.from_email == "some from_email"
#       assert orgsettings.from_email_name == "some from_email_name"
#       assert orgsettings.org_name == "some org_name"
#       assert orgsettings.support_email == "some support_email"
#       assert orgsettings.tenant_name == "some tenant_name"
#       assert orgsettings.url == "some url"
#     end

#     test "create_orgsettings/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Admin.create_orgsettings(@invalid_attrs, @tenant)
#     end

#     test "update_orgsettings/2 with valid data updates the orgsettings" do
#       orgsettings = Factory.insert(:orgsettings, [], prefix: @prefix)
      
#       assert {:ok, %Orgsettings{} = orgsettings} = Admin.update_orgsettings(orgsettings, @update_attrs)
#       assert orgsettings.from_email == "some updated from_email"
#       assert orgsettings.from_email_name == "some updated from_email_name"
#       assert orgsettings.org_name == "some updated org_name"
#       assert orgsettings.support_email == "some updated support_email"
#       assert orgsettings.tenant_name == "some updated tenant_name"
#       assert orgsettings.url == "some updated url"
#     end

#     test "update_orgsettings/2 with invalid data returns error changeset" do
#       orgsettings = Factory.insert(:orgsettings, [], prefix: @prefix)
#       assert {:error, %Ecto.Changeset{}} = Admin.update_orgsettings(orgsettings, @invalid_attrs)
#       assert orgsettings == Admin.get_orgsettings!(orgsettings.id, @tenant)
#     end

#     test "delete_orgsettings/1 deletes the orgsettings" do
#       orgsettings = Factory.insert(:orgsettings, [], prefix: @prefix)
#       assert {:ok, %Orgsettings{}} = Admin.delete_orgsettings(orgsettings)
#       assert_raise Ecto.NoResultsError, fn -> Admin.get_orgsettings!(orgsettings.id, @tenant) end
#     end

#     test "change_orgsettings/1 returns a orgsettings changeset" do
#       orgsettings = Factory.insert(:orgsettings, [], prefix: @prefix)
#       assert %Ecto.Changeset{} = Admin.change_orgsettings(orgsettings)
#     end
#   end
# end
