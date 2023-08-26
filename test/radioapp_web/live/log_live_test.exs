defmodule RadioappWeb.LogLiveTest do
  use RadioappWeb.ConnCase, async: true

  alias Radioapp.Factory
  import Phoenix.LiveViewTest

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  @create_attrs %{
  host_name: "some host name",
  notes: "some notes",
  category: "Popular Music",
  date: ~D[2023-02-18], 
  start_time: ~T[01:11:00Z], 
  end_time: ~T[01:13:00Z], 
  language: "English"
  }
  @update_attrs %{  host_name: "some updated host name",
  notes: "some updated notes",
  category: "Spoken Word",
  date: ~D[2023-03-18], 
  start_time: ~T[02:11:00Z], 
  end_time: ~T[02:13:00Z], 
  language: "French"
  }
  @invalid_attrs %{
    notes: nil, 
    category: "Spoken Word",
    date: nil,
    start_time: nil, 
    end_time: nil, 
    host_name: nil,
    language: nil
  }
  describe "Connection Tests" do
    test "disconnected and connected render without authentication should redirect to login page",
         %{conn: conn} do
      # If we don't previously log in we will be redirected to the login page
          
      assert {:error, redirect} = live(conn, ~p"/admin/logs")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash

    end
  end

  describe "Don't allow users to access functions" do
    setup %{conn: conn} do
      user = Factory.insert(:user, role: "user")
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "Does not list all logs for non-admin user", %{conn: conn} do
      Factory.insert(:link, [], prefix: @prefix)
      assert {:error, redirect} = live(conn, ~p"/admin/logs")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/"
      assert %{"error" => "Unauthorised"} = flash
    end
  end
  describe "Index" do
    setup %{conn: conn} do
      user = Factory.insert(:user, role: "admin")
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end   
    test "lists all logs", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)
      log = Factory.insert(:log, [program: program], prefix: @prefix)
      {:ok, _index_live, html} = live(conn, ~p"/programs/#{program}/logs")

      assert html =~ "Listing Logs"
      assert html =~ log.notes
    end

    test "saves new log", %{conn: conn} do
      
      program = Factory.insert(:program, [], prefix: @prefix)

      {:ok, index_live, _html} = live(conn, ~p"/programs/#{program}/logs")

      assert index_live  |> element("a", "Add Log") |> render_click() =~
               "Add Log"

      assert_patch(index_live, ~p"/programs/#{program}/logs/new")

      assert index_live
             |> form("#log-form", log: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#log-form", log: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/programs/#{program}/logs")

      assert html =~ "Log created successfully"
      assert html =~ "some notes"
      
      
    end

    test "updates log in listing", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)
      log = Factory.insert(:log, [program: program], prefix: @prefix)

      {:ok, index_live, _html} = live(conn, ~p"/programs/#{program}/logs")

      assert index_live |> element("#logs-#{log.id} a", "Edit") |> render_click() =~
               "Edit Log"

      assert_patch(index_live, ~p"/programs/#{program}/logs/#{log}/edit")

      assert index_live
             |> form("#log-form", log: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#log-form", log: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/programs/#{program}/logs")

      assert html =~ "Log updated successfully"
      assert html =~ "some updated notes"
      
      
    end

    test "deletes log in listing", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)

      _log = Factory.insert(:log, [program_id: program.id], prefix: @prefix)

      assert {:error, redirect}  = live(conn, ~p"/programs/#{program}/logs")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/"
      assert %{"error" => "Unauthorised"} = flash
    end
  end

  describe "Delete log with admin" do
    setup %{conn: conn} do
      user = Factory.insert(:user, role: "admin")
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "deletes log in listing", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)

      log = Factory.insert(:log, [program_id: program.id], prefix: @prefix)

      {:ok, index_live, _html} = live(conn, ~p"/programs/#{program}/logs")

      assert index_live |> element("#logs-#{log.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#log-#{log.id}")
    end
  end


  describe "Show" do
    setup %{conn: conn} do
      user = Factory.insert(:user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "displays log", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)
      log = Factory.insert(:log, [program: program], prefix: @prefix)

      {:ok, _show_live, html} = live(conn, ~p"/programs/#{program}/logs/#{log}")

      assert html =~ "Log"
      assert html =~ log.notes
    end

    test "updates log within modal", %{conn: conn} do
      program = Factory.insert(:program, [], prefix: @prefix)
      log = Factory.insert(:log, [program: program], prefix: @prefix)

      {:ok, show_live, _html} = live(conn, ~p"/programs/#{program}/logs/#{log}")

      assert show_live |> element("a", "Edit Log") |> render_click() =~
               "Edit Log"

      assert_patch(show_live, ~p"/programs/#{program}/logs/#{log}/show/edit")

      assert show_live
             |> form("#log-form", log: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#log-form", log: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/programs/#{program}/logs/#{log}")

      assert html =~ "Log updated successfully"
      assert html =~ "some updated notes"
    end
  end
end
