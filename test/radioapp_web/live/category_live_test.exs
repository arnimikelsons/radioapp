defmodule RadioappWeb.CategoryLiveTest do
  use RadioappWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Radioapp.Factory

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  @create_attrs %{code: "some code", name: "some name"}
  @update_attrs %{code: "some updated code", name: "some updated name"}
  @invalid_attrs %{code: nil, name: nil}


  describe "Connection Tests" do
    test "disconnected and connected render without authentication should redirect to login page",
         %{conn: conn} do
      # If we don't previously log in we will be redirected to the login page

      assert {:error, redirect} = live(conn, ~p"/admin/links")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash

    end
  end

  describe "Test for non-admin user not allowed" do

    setup %{conn: conn} do

      user = Factory.insert(:user, role: "user")
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "Does not list all categories", %{conn: conn} do
      Factory.insert(:category, [], prefix: @prefix)
      assert {:error, redirect} = live(conn, ~p"/admin/categories")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/"
      assert %{"error" => "Unauthorised"} = flash
    end
  end

  describe "Index" do

    setup %{conn: conn} do

      user = Factory.insert(:user, role: "admin")
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end


    test "lists all categories", %{conn: conn} do
      category = Factory.insert(:category, [], prefix: @prefix)
      {:ok, _index_live, html} = live(conn, ~p"/admin/categories")

      assert html =~ "Listing Categories"
      assert html =~ category.code
    end

    test "saves new category", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/categories")

      assert index_live |> element("a", "New Category") |> render_click() =~
               "New Category"

      assert_patch(index_live, ~p"/admin/categories/new")

      assert index_live
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#category-form", category: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/categories")

      assert html =~ "Category created successfully"
      assert html =~ "some code"
    end

    test "updates category in listing", %{conn: conn} do
      category = Factory.insert(:category, [], prefix: @prefix)
      {:ok, index_live, _html} = live(conn, ~p"/admin/categories")

      assert index_live |> element("#categories-#{category.id} a", "Edit") |> render_click() =~
               "Edit Category"

      assert_patch(index_live, ~p"/admin/categories/#{category}/edit")

      assert index_live
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#category-form", category: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/categories")

      assert html =~ "Category updated successfully"
      assert html =~ "some updated code"
    end

    test "deletes category in listing", %{conn: conn} do
      category = Factory.insert(:category, [], prefix: @prefix)
      {:ok, index_live, _html} = live(conn, ~p"/admin/categories")

      assert index_live |> element("#categories-#{category.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#category-#{category.id}")
    end
  end

  describe "Show" do
    setup %{conn: conn} do
      user = Factory.insert(:user, role: "admin")
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end


    test "displays category", %{conn: conn} do
      category = Factory.insert(:category, [], prefix: @prefix)
      {:ok, _show_live, html} = live(conn, ~p"/admin/categories/#{category}")

      assert html =~ "Show Category"
      assert html =~ category.code
    end

    test "updates category within modal", %{conn: conn} do
      category = Factory.insert(:category, [], prefix: @prefix)
      {:ok, show_live, _html} = live(conn, ~p"/admin/categories/#{category}")

      assert show_live |> element("a", "Edit Category") |> render_click() =~
               "Edit Category"

      assert_patch(show_live, ~p"/admin/categories/#{category}/show/edit")

      assert show_live
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#category-form", category: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/categories/#{category}")

      assert html =~ "Category updated successfully"
      assert html =~ "some updated code"
    end
  end
end
