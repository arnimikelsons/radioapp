defmodule RadioappWeb.ProgramControllerTest do
  use RadioappWeb.ConnCase

  alias Radioapp.Factory

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  @create_attrs %{description: "some description", genre: "some genre", name: "some name", short_description: "some short description"}
  @update_attrs %{description: "some updated description", genre: "some updated genre", name: "some updated name", short_description: "some updated short description"}
  @invalid_attrs %{description: nil, genre: nil, name: nil}

  describe "index" do
    test "lists all programs", %{conn: conn} do
      conn = get(conn, ~p"/programs")
      assert html_response(conn, 200) =~ "RadioApp Programs"
    end
  end

  describe "manage programs" do
    setup %{conn: conn} do
      user = Factory.insert(:user, roles: %{@tenant => "user"}, full_name: "Some Full Name")
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/programs/new")
      assert html_response(conn, 200) =~ "New Program"
    end


    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/programs", program: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/programs/#{id}"

      conn = get(conn, ~p"/programs/#{id}")
      assert html_response(conn, 200) =~ "Edit Program"
      # there are no timeslots so show that there are no archives
      assert html_response(conn, 200) =~ "No archives available"

    end

    test "renders errors when data is invalid for New Program", %{conn: conn} do
      conn = post(conn, ~p"/programs", program: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Program"
    end

    test "renders form for editing chosen program", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)
      conn = get(conn, ~p"/programs/#{program}/edit")
      assert html_response(conn, 200) =~ "Edit Program"
    end

    test "redirects when data is valid", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)

      conn = put(conn, ~p"/programs/#{program}", program: @update_attrs)
      assert redirected_to(conn) == ~p"/programs/#{program}"

      conn = get(conn, ~p"/programs/#{program}")
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid for Edit", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)

      conn = put(conn, ~p"/programs/#{program}", program: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Program"
    end

    # no delete of programs (they are archived)
    # test "deletes chosen program", %{conn: conn, user: user} do

    #   program = Factory.insert(:program, [], prefix: @prefix)
    #   conn = delete(conn, ~p"/programs/#{program}")
    #   assert redirected_to(conn) == ~p"/programs"

    #   conn = get(conn, ~p"/programs/#{program}")
      
    #   assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "User updated successfully."
    # end
  end

  describe "delete programs for admin" do
    setup %{conn: conn} do
      user = Factory.insert(:user, role: "admin")
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    # delete removed
    # test "deletes chosen program", %{conn: conn} do
    #   program = Factory.insert(:program, [], prefix: @prefix)
    #   conn = delete(conn, ~p"/programs/#{program}")
    #   assert redirected_to(conn) == ~p"/"

    #   assert_error_sent 404, fn ->
    #     get(conn, ~p"/programs/#{program}")
    #   end
    #end
  end
end
