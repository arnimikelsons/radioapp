defmodule RadioappWeb.UserControllerTest do
  use RadioappWeb.ConnCase

  alias Radioapp.Factory

  describe "manage users" do
    setup %{conn: conn} do
      current_user = Factory.insert(:user, role: "admin")
      conn = log_in_user(conn, current_user)
      %{conn: conn, user: current_user}
    end

    test "lists all users", %{conn: conn} do
      conn = get(conn, ~p"/users")
      assert html_response(conn, 200) =~ "Account Users"
    end

    test "renders form for editing chosen user", %{conn: conn} do
      user = Factory.insert(:user)
      conn = get(conn, ~p"/users/#{user}/edit")
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "redirects when data is valid", %{conn: conn} do
      user = Factory.insert(:user, full_name: "Some Full Name")

      conn = put(conn, ~p"/users/#{user}", user: %{full_name: "Some Updated Full Name"})
      assert redirected_to(conn) == ~p"/users"

      conn = get(conn, ~p"/users/")
      assert html_response(conn, 200) =~ "Some Updated Full Name"
    end

    test "renders errors when data is invalid for Edit", %{conn: conn} do
      user = Factory.insert(:user)

      conn = put(conn, ~p"/users/#{user}", user: %{full_name: nil})
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "deletes chosen user", %{conn: conn} do
      user = Factory.insert(:user, full_name: "Some Full Name")
      conn = delete(conn, ~p"/users/#{user}")
      assert redirected_to(conn) == ~p"/users"
      
    end
  end
end
