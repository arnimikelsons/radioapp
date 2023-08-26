defmodule RadioappWeb.LinkLiveTest do
  use RadioappWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Radioapp.Factory

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  @create_attrs %{icon: "some icon", type: "some type"}
  @update_attrs %{icon: "some updated icon", type: "some updated type"}
  @invalid_attrs %{icon: nil, type: nil}

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

    test "Does not list all links for non-admin user", %{conn: conn} do
      Factory.insert(:link, [], prefix: @prefix)
      assert {:error, redirect} = live(conn, ~p"/admin/links")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/"
      assert %{"error" => "Unauthorised"} = flash
    end
  end

  describe "Index" do
    setup %{conn: conn} do
      user = Factory.insert(:user, [role: "admin"])
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "lists all links", %{conn: conn} do
      link = Factory.insert(:link, [], prefix: @prefix)
      {:ok, _index_live, html} = live(conn, ~p"/admin/links")

      assert html =~ "Listing Links"
      assert html =~ link.icon
    end

    test "saves new link", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/links")

      assert index_live |> element("a", "New Link") |> render_click() =~
               "New Link"

      assert_patch(index_live, ~p"/admin/links/new")

      assert index_live
             |> form("#link-form", link: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#link-form", link: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/links")

      assert html =~ "Link created successfully"
      assert html =~ "some icon"
    end

    test "updates link in listing", %{conn: conn} do
      link = Factory.insert(:link, [], prefix: @prefix)
      {:ok, index_live, _html} = live(conn, ~p"/admin/links")

      assert index_live |> element("#links-#{link.id} a", "Edit") |> render_click() =~
               "Edit Link"

      assert_patch(index_live, ~p"/admin/links/#{link}/edit")

      assert index_live
             |> form("#link-form", link: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#link-form", link: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/links")

      assert html =~ "Link updated successfully"
      assert html =~ "some updated icon"
    end

    test "deletes link in listing", %{conn: conn} do
      link = Factory.insert(:link, [], prefix: @prefix)
      {:ok, index_live, _html} = live(conn, ~p"/admin/links")

      assert index_live |> element("#links-#{link.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#link-#{link.id}")
    end
  end

  describe "Show" do
    setup %{conn: conn} do
      user = Factory.insert(:user, role: "admin")
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    # not used
    # test "displays link", %{conn: conn} do
    #   link = Factory.insert(:link, [], prefix: @prefix)
    #   {:ok, _show_live, html} = live(conn, ~p"/admin/links/#{link}")

    #   assert html =~ "Show Link"
    #   assert html =~ link.icon
    # end

    # test "updates link within modal", %{conn: conn} do
    #   link = Factory.insert(:link, [], prefix: @prefix)
    #   {:ok, show_live, _html} = live(conn, ~p"/admin/links/#{link}")

    #   assert show_live |> element("a", "Edit Link") |> render_click() =~
    #            "Edit Link"

    #   assert_patch(show_live, ~p"/admin/links/#{link}/show/edit")

      #no invalid case
      #assert show_live
      #       |> form("#link-form", link: @invalid_attrs)
      #       |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#link-form", link: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/links/#{link}")

      assert html =~ "Link updated successfully"
      assert html =~ "some updated icon"
    end
  end
end
