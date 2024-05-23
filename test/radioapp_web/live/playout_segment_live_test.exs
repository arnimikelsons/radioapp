defmodule RadioappWeb.PlayoutSegmentLiveTest do
  use RadioappWeb.ConnCase
  alias Radioapp.Factory

  import Phoenix.LiveViewTest

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  # @create_attrs %{
  #   artist: "some artist",
  #   can_con: true,
  #   catalogue_number: "12345",
  #   category_id: 1,
  #   start_time: ~T[02:11:00Z],
  #   end_time: ~T[02:13:00Z],
  #   hit: true,
  #   instrumental: false,
  #   new_music: true,
  #   socan_type: "Feature",
  #   song_title: "some song title",
  #   indigenous_artist: true,
  #   emerging_artist: false
  # }
  @update_attrs %{
    artist: "some updated artist",
    can_con: false,
    catalogue_number: "54321",
    start_time: ~T[03:11:00Z],
    end_time: ~T[03:13:00Z],
    hit: false,
    instrumental: true,
    new_music: false,
    socan_type: "Background",
    song_title: "some updated song title",
    indigenous_artist: false,
    emerging_artist: true
  }

  @invalid_attrs %{
    artist: nil,
    can_con: false,
    catalogue_number: nil,
    start_time: nil,
    end_time: nil,
    hit: false,
    instrumental: false,
    new_music: false,
    socan_type: " ",
    song_title: nil,
    indigenous_artist: false,
    emerging_artist: false
  }
  describe "Connection Tests" do
    test "disconnected and connected render without authentication should redirect to login page",
         %{conn: conn} do
      # If we don't previously log in we will be redirected to the login page

      assert {:error, redirect} = live(conn, ~p"/playout_segments")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash

    end
  end

  describe "Index" do
    setup %{conn: conn} do
      user = Factory.insert(:user, roles: %{@tenant => "user"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "lists all playout segments", %{conn: conn} do
      playout_segment = Factory.insert(:playout_segment, [], prefix: @prefix)

      {:ok, _index_live, html} = live(conn, ~p"/playout_segments")

      assert html =~ "Playout System"
      assert html =~ playout_segment.song_title
    end

    test "updates segment in listing", %{conn: conn} do
      category = Factory.insert(:category, [], prefix: @prefix)
      playout_segment = Factory.insert(:playout_segment, [category: category], prefix: @prefix)

      {:ok, index_live, _html} = live(conn, ~p"/playout_segments")

      assert index_live |> element("#segments-#{playout_segment.id} a", "Edit") |> render_click() =~
               "Edit Playout Segment"

      assert_patch(index_live, ~p"/playout_segments/#{playout_segment.id}/edit")

      assert index_live
             |> form("#playout-segment-form", playout_segment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#playout-segment-form", playout_segment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/playout_segments")

      assert html =~ "Segment updated successfully"
      assert html =~ "some updated song title"
    end

    test "Disable delete segment button", %{conn: conn} do
      category = Factory.insert(:category, [], prefix: @prefix)
      _playout_segment = Factory.insert(:playout_segment, [category: category], prefix: @prefix)

      {:ok, _index_live, html} = live(conn, ~p"/playout_segments")

      refute html =~ "Delete"

    end
  end

  describe "Delete for Admin" do
    setup %{conn: conn} do
      user = Factory.insert(:user, roles: %{@tenant => "admin"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "deletes segment in listing", %{conn: conn} do
      category = Factory.insert(:category, [], prefix: @prefix)
      playout_segment = Factory.insert(:playout_segment, [category: category], prefix: @prefix)

      {:ok, index_live, _html} = live(conn, ~p"/playout_segments")

      assert index_live |> element("#playout-segment-#{playout_segment.id}", "Delete") |> render_click()
      refute has_element?(index_live, "#playout-segment-#{playout_segment.id}")
    end
  end


  describe "User Playout Segment Edit" do
    setup %{conn: conn} do
      user = Factory.insert(:user, roles: %{@tenant => "user"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "updates playout_segment within modal", %{conn: conn} do
      category = Factory.insert(:category, [], prefix: @prefix)
      playout_segment = Factory.insert(:playout_segment, [category: category], prefix: @prefix)

      {:ok, show_live, _html} = live(conn, ~p"/playout_segments")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Playout Segment"

      assert_patch(show_live, ~p"/playout_segments/#{playout_segment}/edit")

      assert show_live
        |> form("#playout-segment-form", playout_segment: @invalid_attrs)
        |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#playout-segment-form", playout_segment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/playout_segments")

      assert html =~ "Segment updated successfully"
      assert html =~ "some updated song title"
    end
  end
end
