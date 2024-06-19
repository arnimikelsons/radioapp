defmodule RadioappWeb.StationdefaultsControllerTest do
  use RadioappWeb.ConnCase

  alias Radioapp.Factory

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  @create_attrs %{callsign: "some callsign", from_email: "some from_email", from_email_name: "some from_email_name", logo_path: "some logo_path", org_name: "some org_name", timezone: "America/Vancouver", phone: "some phone", playout_url: "some playout_url", privacy_policy_url: "some privacy_policy_url", support_email: "some support_email", tos_url: "some tos_url", website_url: "some website_url"}
  @update_attrs %{callsign: "some updated callsign", from_email: "some updated from_email", from_email_name: "some updated from_email_name", logo_path: "some updated logo_path", org_name: "some updated org_name", timezone: "Canada/Newfoundland", phone: "some updated phone", playout_url: "some updated playout_url", privacy_policy_url: "some updated privacy_policy_url", support_email: "some updated support_email", tos_url: "some updated tos_url", website_url: "some updated website_url"}
  @invalid_attrs %{callsign: "CYYK", from_email: nil, from_email_name: nil, logo_path: nil, org_name: nil, timezone: nil, phone: nil, playout_url: nil, privacy_policy_url: nil, support_email: nil, tos_url: nil, website_url: nil}

  describe "manage stationdefaults" do

    setup %{conn: conn} do
      user = Factory.insert(:user, roles: %{@tenant => "admin"})

      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "lists all stationdefaults", %{conn: conn} do
      conn = get(conn, ~p"/stationdefaults")
      assert html_response(conn, 200) =~ "Listing Station Defaults"
    end

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/stationdefaults", stationdefaults: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/stationdefaults/#{id}"

      conn = get(conn, ~p"/stationdefaults/#{id}")
      assert html_response(conn, 200) =~ "Station defaults"
    end

    test "renders form for editing chosen stationdefaults", %{conn: conn} do
      stationdefaults = Factory.insert(:stationdefaults, [], prefix: @prefix)
      conn = get(conn, ~p"/stationdefaults/#{stationdefaults}/edit")
      assert html_response(conn, 200) =~ "Edit Station Defaults"
    end

    test "redirects when data is valid", %{conn: conn} do
      stationdefaults = Factory.insert(:stationdefaults, [], prefix: @prefix)
      conn = put(conn, ~p"/stationdefaults/#{stationdefaults}", stationdefaults: @update_attrs)
      assert redirected_to(conn) == ~p"/stationdefaults/#{stationdefaults}/edit"

      conn = get(conn, ~p"/stationdefaults/#{stationdefaults}")
      assert html_response(conn, 200) =~ "some updated callsign"
    end

    test "renders errors when stationdefaults data is invalid", %{conn: conn} do
      stationdefaults = Factory.insert(:stationdefaults, [], prefix: @prefix)
      conn = put(conn, ~p"/stationdefaults/#{stationdefaults}", stationdefaults: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Station Defaults"
    end

    test "deletes chosen stationdefaults", %{conn: conn} do
      stationdefaults = Factory.insert(:stationdefaults, [], prefix: @prefix)
      conn = delete(conn, ~p"/stationdefaults/#{stationdefaults}")
      assert redirected_to(conn) == ~p"/stationdefaults"

    end
  end
end
