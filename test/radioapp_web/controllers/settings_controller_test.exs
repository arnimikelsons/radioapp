defmodule RadioappWeb.SettingsControllerTest do
  use RadioappWeb.ConnCase

  import Radioapp.AdminFixtures

  @create_attrs %{callsign: "some callsign", from_email: "some from_email", from_email_name: "some from_email_name", logo_path: "some logo_path", org_name: "some org_name", phone: "some phone", playout_url: "some playout_url", privacy_policy_url: "some privacy_policy_url", support_email: "some support_email", tos_url: "some tos_url", website_url: "some website_url"}
  @update_attrs %{callsign: "some updated callsign", from_email: "some updated from_email", from_email_name: "some updated from_email_name", logo_path: "some updated logo_path", org_name: "some updated org_name", phone: "some updated phone", playout_url: "some updated playout_url", privacy_policy_url: "some updated privacy_policy_url", support_email: "some updated support_email", tos_url: "some updated tos_url", website_url: "some updated website_url"}
  @invalid_attrs %{callsign: nil, from_email: nil, from_email_name: nil, logo_path: nil, org_name: nil, phone: nil, playout_url: nil, privacy_policy_url: nil, support_email: nil, tos_url: nil, website_url: nil}

  describe "index" do
    test "lists all settings", %{conn: conn} do
      conn = get(conn, ~p"/settings")
      assert html_response(conn, 200) =~ "Listing Settings"
    end
  end

  describe "new settings" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/settings/new")
      assert html_response(conn, 200) =~ "New Settings"
    end
  end

  describe "create settings" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/settings", settings: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/settings/#{id}"

      conn = get(conn, ~p"/settings/#{id}")
      assert html_response(conn, 200) =~ "Settings #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/settings", settings: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Settings"
    end
  end

  describe "edit settings" do
    setup [:create_settings]

    test "renders form for editing chosen settings", %{conn: conn, settings: settings} do
      conn = get(conn, ~p"/settings/#{settings}/edit")
      assert html_response(conn, 200) =~ "Edit Settings"
    end
  end

  describe "update settings" do
    setup [:create_settings]

    test "redirects when data is valid", %{conn: conn, settings: settings} do
      conn = put(conn, ~p"/settings/#{settings}", settings: @update_attrs)
      assert redirected_to(conn) == ~p"/settings/#{settings}"

      conn = get(conn, ~p"/settings/#{settings}")
      assert html_response(conn, 200) =~ "some updated callsign"
    end

    test "renders errors when data is invalid", %{conn: conn, settings: settings} do
      conn = put(conn, ~p"/settings/#{settings}", settings: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Settings"
    end
  end

  describe "delete settings" do
    setup [:create_settings]

    test "deletes chosen settings", %{conn: conn, settings: settings} do
      conn = delete(conn, ~p"/settings/#{settings}")
      assert redirected_to(conn) == ~p"/settings"

      assert_error_sent 404, fn ->
        get(conn, ~p"/settings/#{settings}")
      end
    end
  end

  defp create_settings(_) do
    settings = settings_fixture()
    %{settings: settings}
  end
end
