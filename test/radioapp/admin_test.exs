defmodule Radioapp.AdminTest do
  use Radioapp.DataCase
  alias Radioapp.Factory
  alias Radioapp.Admin.{Category, Link}
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

  describe "settings" do
    alias Radioapp.Admin.Settings

    import Radioapp.AdminFixtures

    @invalid_attrs %{callsign: nil, from_email: nil, from_email_name: nil, logo_path: nil, org_name: nil, phone: nil, playout_url: nil, privacy_policy_url: nil, support_email: nil, tos_url: nil, website_url: nil}

    test "list_settings/0 returns all settings" do
      settings = settings_fixture()
      assert Admin.list_settings() == [settings]
    end

    test "get_settings!/1 returns the settings with given id" do
      settings = settings_fixture()
      assert Admin.get_settings!(settings.id) == settings
    end

    test "create_settings/1 with valid data creates a settings" do
      valid_attrs = %{callsign: "some callsign", from_email: "some from_email", from_email_name: "some from_email_name", logo_path: "some logo_path", org_name: "some org_name", phone: "some phone", playout_url: "some playout_url", privacy_policy_url: "some privacy_policy_url", support_email: "some support_email", tos_url: "some tos_url", website_url: "some website_url"}

      assert {:ok, %Settings{} = settings} = Admin.create_settings(valid_attrs)
      assert settings.callsign == "some callsign"
      assert settings.from_email == "some from_email"
      assert settings.from_email_name == "some from_email_name"
      assert settings.logo_path == "some logo_path"
      assert settings.org_name == "some org_name"
      assert settings.phone == "some phone"
      assert settings.playout_url == "some playout_url"
      assert settings.privacy_policy_url == "some privacy_policy_url"
      assert settings.support_email == "some support_email"
      assert settings.tos_url == "some tos_url"
      assert settings.website_url == "some website_url"
    end

    test "create_settings/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Admin.create_settings(@invalid_attrs)
    end

    test "update_settings/2 with valid data updates the settings" do
      settings = settings_fixture()
      update_attrs = %{callsign: "some updated callsign", from_email: "some updated from_email", from_email_name: "some updated from_email_name", logo_path: "some updated logo_path", org_name: "some updated org_name", phone: "some updated phone", playout_url: "some updated playout_url", privacy_policy_url: "some updated privacy_policy_url", support_email: "some updated support_email", tos_url: "some updated tos_url", website_url: "some updated website_url"}

      assert {:ok, %Settings{} = settings} = Admin.update_settings(settings, update_attrs)
      assert settings.callsign == "some updated callsign"
      assert settings.from_email == "some updated from_email"
      assert settings.from_email_name == "some updated from_email_name"
      assert settings.logo_path == "some updated logo_path"
      assert settings.org_name == "some updated org_name"
      assert settings.phone == "some updated phone"
      assert settings.playout_url == "some updated playout_url"
      assert settings.privacy_policy_url == "some updated privacy_policy_url"
      assert settings.support_email == "some updated support_email"
      assert settings.tos_url == "some updated tos_url"
      assert settings.website_url == "some updated website_url"
    end

    test "update_settings/2 with invalid data returns error changeset" do
      settings = settings_fixture()
      assert {:error, %Ecto.Changeset{}} = Admin.update_settings(settings, @invalid_attrs)
      assert settings == Admin.get_settings!(settings.id)
    end

    test "delete_settings/1 deletes the settings" do
      settings = settings_fixture()
      assert {:ok, %Settings{}} = Admin.delete_settings(settings)
      assert_raise Ecto.NoResultsError, fn -> Admin.get_settings!(settings.id) end
    end

    test "change_settings/1 returns a settings changeset" do
      settings = settings_fixture()
      assert %Ecto.Changeset{} = Admin.change_settings(settings)
    end
  end
end
