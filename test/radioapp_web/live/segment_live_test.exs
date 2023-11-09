defmodule RadioappWeb.SegmentLiveTest do
  use RadioappWeb.ConnCase
  alias Radioapp.Factory

  import Phoenix.LiveViewTest

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  @create_attrs %{
    artist: "some artist",
    can_con: true,
    catalogue_number: "12345",
    category_id: 1,
    start_time: ~T[02:11:00Z],
    end_time: ~T[02:13:00Z],
    hit: true,
    instrumental: false,
    new_music: true,
    song_title: "some song title"
  }
  @update_attrs %{
    artist: "some updated artist",
    can_con: false,
    catalogue_number: "54321",
    start_time: ~T[03:11:00Z],
    end_time: ~T[03:13:00Z],
    hit: false,
    instrumental: true,
    new_music: false,
    song_title: "some updated song title"
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
    song_title: nil
  }
  describe "Connection Tests" do
    test "disconnected and connected render without authentication should redirect to login page",
         %{conn: conn} do
      # If we don't previously log in we will be redirected to the login page

      assert {:error, redirect} = live(conn, ~p"/admin/categories")

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

    test "lists all segments", %{conn: conn} do
      
      program = Factory.insert(:program, [], prefix: @prefix)
      log = Factory.insert(:log, [program: program], prefix: @prefix)
      category = Factory.insert(:category, [], prefix: @prefix)
      segment = Factory.insert(:segment, [log: log, category: category], prefix: @prefix)
      {:ok, _index_live, html} = live(conn, ~p"/programs/#{program}/logs/#{log}/segments")

      assert html =~ "Listing Segments"
      assert html =~ segment.song_title
    end

    test "saves new segment", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)
      log = Factory.insert(:log, [program: program], prefix: @prefix)
      _valid_category = Factory.insert(:category, [id: 1], prefix: @prefix)

      {:ok, index_live, _html}= live(conn, ~p"/programs/#{program}/logs/#{log}/segments")

      assert index_live |> element("a", "New Segment") |> render_click() =~
               "New Segment"

      assert_patch(index_live, ~p"/programs/#{program}/logs/#{log}/segments/new")

      assert index_live
             |> form("#segment-form", segment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#segment-form", segment: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/programs/#{program}/logs/#{log}/segments/new")

      assert html =~ "Segment created successfully"
      assert html =~ "some song title"
    end

    test "updates segment in listing", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)
      log = Factory.insert(:log, [program: program], prefix: @prefix)
      category = Factory.insert(:category, [], prefix: @prefix)
      segment = Factory.insert(:segment, [log: log, category: category], prefix: @prefix)

      {:ok, index_live, _html} = live(conn, ~p"/programs/#{program}/logs/#{log}/segments")

      assert index_live |> element("#segments-#{segment.id} a", "Edit") |> render_click() =~
               "Edit Segment"

      assert_patch(index_live, ~p"/programs/#{program}/logs/#{log}/segments/#{segment}/edit")

      assert index_live
             |> form("#segment-form", segment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#segment-form", segment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/programs/#{program}/logs/#{log}/segments")

      assert html =~ "Segment updated successfully"
      assert html =~ "some updated song title"
    end

    test "deletes segment in listing", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)
      log = Factory.insert(:log, [program: program], prefix: @prefix)
      category = Factory.insert(:category, [], prefix: @prefix)
      _segment = Factory.insert(:segment, [log: log, category: category], prefix: @prefix)

      {:ok, _index_live, html} = live(conn, ~p"/programs/#{program}/logs/#{log}/segments")

      refute html =~ "Delete"

    end
  end

  describe "Delete for Admin" do
    setup %{conn: conn} do
      user = Factory.insert(:user, roles: %{@tenant => "admin"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    # delete not implemented
    # test "deletes segment in listing", %{conn: conn} do
    #   program = Factory.insert(:program, [], prefix: @prefix)
    #   log = Factory.insert(:log, [program: program], prefix: @prefix)
    #   category = Factory.insert(:category, [], prefix: @prefix)
    #   segment = Factory.insert(:segment, [log: log, category: category], prefix: @prefix)

    #   {:ok, index_live, _html} = live(conn, ~p"/programs/#{program}/logs/#{log}/segments")

    #   assert index_live |> element("#segments-#{segment.id} a", "Delete") |> render_click()
    #   refute has_element?(index_live, "#segment-#{segment.id}")
    # end
  end


  describe "Segment" do
    setup %{conn: conn} do
      user = Factory.insert(:user, roles: %{@tenant => "user"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "updates segment within modal", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)
      log = Factory.insert(:log, [program: program], prefix: @prefix)
      category = Factory.insert(:category, [], prefix: @prefix)
      segment = Factory.insert(:segment, [log: log, category: category], prefix: @prefix)

      {:ok, show_live, _html} = live(conn, ~p"/programs/#{program}/logs/#{log}/segments")

      assert show_live |> element("a", "Edit Segment") |> render_click() =~
               "Edit Segment"

      assert_patch(show_live, ~p"/programs/#{program}/logs/#{log}/segments/#{segment}/edit")

      assert show_live
        |> form("#segment-form", segment: @invalid_attrs)
        |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#segment-form", segment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/programs/#{program}/logs/#{log}/segments")

      assert html =~ "Segment updated successfully"
      assert html =~ "some updated song title"
    end
  end
end
