defmodule RadioappWeb.UserControllerTest do
  use RadioappWeb.ConnCase

  alias Radioapp.Factory
  @tenant "sample"
  @another_tenant "not_sample"

  describe "manage users" do
    setup %{conn: conn} do
      user = Factory.insert(:user, roles: %{@tenant => "admin"}, full_name: "Some Full Name")
      _user2 = Factory.insert(:user, roles: %{@another_tenant => "admin"}, full_name: "Different Full Name")

      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "lists all users", %{conn: conn} do
      
      conn = get(conn, ~p"/users")
      assert html_response(conn, 200) =~ "Some Full Name"
      refute html_response(conn, 200) =~ "Different Full Name"
    end

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, ~p"/users/#{user}/edit")
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "redirects when data is valid", %{conn: conn} do
      target_user = Factory.insert(:user, roles: %{@tenant => "admin"}, full_name: "Some Full Name")

      conn = put(conn, ~p"/users/#{target_user}", user: %{full_name: "Some Updated Full Name", tenant_role: target_user.roles[@tenant]})
      assert redirected_to(conn) == ~p"/users"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "User updated successfully."
      conn = get(conn, ~p"/users/")
      assert html_response(conn, 200) =~ "Some Updated Full Name"
    end

    test "renders errors when data is invalid for Edit", %{conn: conn, user: user} do

      conn = put(conn, ~p"/users/#{user}", user: %{full_name: nil})
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/users/#{user}")
      assert redirected_to(conn) == ~p"/users" 
    end
  end
end
