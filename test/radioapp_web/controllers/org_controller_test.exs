defmodule RadioappWeb.OrgControllerTest do
  use RadioappWeb.ConnCase

  import Radioapp.AccountsFixtures

  alias Radioapp.Factory

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  @create_attrs %{address1: "some address1", address2: "some address2", city: "some city", country: "some country", email: "some email", full_name: "some full_name", organization: "some organization", postal_code: "some postal_code", province: "some province", short_name: "some short_name", telephone: "some telephone", tenant_name: "some tenant_name"}
  @update_attrs %{address1: "some updated address1", address2: "some updated address2", city: "some updated city", country: "some updated country", email: "some updated email", full_name: "some updated full_name", organization: "some updated organization", postal_code: "some updated postal_code", province: "some updated province", short_name: "some updated short_name", telephone: "some updated telephone", tenant_name: "some updated tenant_name"}
  @invalid_attrs %{address1: nil, address2: nil, city: nil, country: nil, email: nil, full_name: nil, organization: nil, postal_code: nil, province: nil, short_name: nil, telephone: nil, tenant_name: nil}

  describe "Org functions for Admin" do
    setup %{conn: conn} do
      user = Factory.insert(:user, roles: %{@tenant => "admin"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "lists all orgs", %{conn: conn} do
      conn = get(conn, ~p"/orgs")
      assert html_response(conn, 200) =~ "Listing Orgs"
    end

    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/orgs/new")
      assert html_response(conn, 200) =~ "New Org"
    end

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/orgs", org: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/orgs/#{id}"

      conn = get(conn, ~p"/orgs/#{id}")
      assert html_response(conn, 200) =~ "Org #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/orgs", org: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Org"
    end
  end

  describe "editing functions for org" do

    setup %{conn: conn} do
      user = Factory.insert(:user, roles: %{@tenant => "admin"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "renders form for editing chosen org", %{conn: conn} do
      org = program = Factory.insert(:org)

      conn = get(conn, ~p"/orgs/#{org}/edit")
      assert html_response(conn, 200) =~ "Edit Org"
    end

    test "redirects when data is valid", %{conn: conn} do
      org = Factory.insert(:org)
      
      conn = put(conn, ~p"/orgs/#{org}", org: @update_attrs)
      assert redirected_to(conn) == ~p"/orgs/#{org}"

      conn = get(conn, ~p"/orgs/#{org}")
      assert html_response(conn, 200) =~ "some updated address1"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      org = Factory.insert(:org)

      conn = put(conn, ~p"/orgs/#{org}", org: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Org"
    end

    test "deletes chosen org", %{conn: conn} do
      org = Factory.insert(:org)

      conn = delete(conn, ~p"/orgs/#{org}")
      assert redirected_to(conn) == ~p"/orgs"

      assert_error_sent 404, fn ->
        get(conn, ~p"/orgs/#{org}")
      end
    end
  end

end
