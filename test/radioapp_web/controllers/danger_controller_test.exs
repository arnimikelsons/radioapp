defmodule RadioappWeb.DangerControllerTest do
  use RadioappWeb.ConnCase

  alias Radioapp.Factory

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  describe "Regular user" do
    setup %{conn: conn} do
      user = Factory.insert(:user, roles: %{@tenant => "user"}, full_name: "Some Full Name")
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "Page will not display for a regular user", %{conn: conn} do
      _playout_segment = Factory.insert(:playout_segment, [song_title: "My Song"], prefix: @prefix)

      conn = get(conn, ~p"/danger/deleteplayout_segments")
      assert redirected_to(conn) == ~p"/"
      refute html_response(conn, 302) =~ "My Song"
    end
  end

  describe "Admin user" do
    setup %{conn: conn} do
      user = Factory.insert(:user, role: "admin")
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "page will not display for an admin", %{conn: conn} do
      _playout_segment = Factory.insert(:playout_segment, [song_title: "Some Song Title"], prefix: @prefix)

      conn = get(conn, ~p"/danger/deleteplayout_segments")
      assert redirected_to(conn) == ~p"/"
      refute html_response(conn, 302) =~ "Some Song Title"

    end
  end

  describe "Super admin" do
    setup %{conn: conn} do
      user = Factory.insert(:user, roles: %{"admin" => "super_admin"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "deletes all the playout segments", %{conn: conn} do
      Factory.insert(:playout_segment, [song_title: "First Song"], prefix: @prefix)
      Factory.insert(:playout_segment, [song_title: "Second Song"], prefix: @prefix)

      conn = get(conn, ~p"/playout_segments")

      assert html_response(conn, 200) =~ "First Song"
      assert html_response(conn, 200) =~ "Second Song"

      conn = put(conn, ~p"/danger/deleteallplayout_segments")

      assert redirected_to(conn) == ~p"/playout_segments"

      refute html_response(conn, 302) =~ "First Song"
      refute html_response(conn, 302) =~ "Second Song"

    end
  end
end
