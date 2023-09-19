defmodule RadioappWeb.UserSettingsLiveTest do
  use RadioappWeb.ConnCase

  alias Radioapp.Accounts
  import Phoenix.LiveViewTest
  import Radioapp.AccountsFixtures
  alias Radioapp.Factory

  @tenant "sample"

  describe "Settings page" do
    setup %{conn: conn} do
      user = Factory.insert(:user, roles: %{@tenant => "admin"})
      conn = log_in_user(conn, user)
      %{conn: conn}
    end

    test "renders settings page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> live(~p"/users/settings")

      assert html =~ "Change Name"
      assert html =~ "Change Password"
    end
  end
  describe "not logged in" do
    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/users/settings")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "update name form" do
    setup %{conn: conn} do
      password = valid_user_password()
      user = Factory.insert(:user, roles: %{@tenant => "admin"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, password: password}
    end

    test "updates the user names", %{conn: conn, password: password, user: user} do
      new_full_name = "Some new full name"
      new_short_name = "Some new short name"

      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      {:ok, conn} =
        lv
        |> form("#name_form", %{
          "current_password" => password,
          "user" => %{"full_name" => new_full_name, "short_name" => new_short_name}
        })
        |> render_submit()
        |> follow_redirect(conn, ~p"/users/settings")

      info = Phoenix.Flash.get(conn.assigns.flash, :info)
      assert info == "Name changed successfully."

      user = Accounts.get_user_from_tenant!(user.id, @tenant)

      assert user.full_name == new_full_name
      assert user.short_name == new_short_name
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> element("#name_form")
        |> render_change(%{
          "action" => "update_name",
          "current_password" => "invalid",
          "user" => %{"full_name" => ""}
        })

      assert result =~ "Change Name"
    end
  end

  describe "update password form" do
    setup %{conn: conn} do
      password = valid_user_password()
      user = Factory.insert(:user, roles: %{@tenant => "admin"}, password: password)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, password: password}
    end

    test "updates the user password", %{conn: conn, user: user, password: password} do
      new_password = valid_user_password()

      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      form =
        form(lv, "#password_form", %{
          "current_password" => password,
          "user" => %{
            "email" => user.email,
            "password" => new_password,
            "password_confirmation" => new_password
          }
        })

      render_submit(form)

      new_password_conn = follow_trigger_action(form, conn)

      assert redirected_to(new_password_conn) == ~p"/users/settings"

      assert get_session(new_password_conn, :user_token) != get_session(conn, :user_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :info) =~
               "Password updated successfully"

      assert Accounts.get_user_by_email_and_password(user.email, new_password)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> element("#password_form")
        |> render_change(%{
          "current_password" => "invalid",
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> form("#password_form", %{
          "current_password" => "invalid",
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })
        |> render_submit()

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
      assert result =~ "is not valid"
    end
  end

  describe "confirm email" do
    setup %{conn: conn} do
      email = unique_user_email()
      user = Factory.insert(:user, email: email)

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{conn: log_in_user(conn, user), token: token, email: email, user: user}
    end

    # No email in the setting
    # test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
    #  {:error, redirect} = live(conn, ~p"/users/settings/confirm_email/#{token}")

    #  assert {:live_redirect, %{to: path, flash: flash}} = redirect
    #  assert path == ~p"/users/settings"
    #  assert %{"info" => message} = flash
    #  assert message == "Email changed successfully."
    #  refute Accounts.get_user_by_email(user.email)
    #  assert Accounts.get_user_by_email(email)

    # use confirm token again
    #  {:error, redirect} = live(conn, ~p"/users/settings/confirm_email/#{token}")
    #  assert {:live_redirect, %{to: path, flash: flash}} = redirect
    #  assert path == ~p"/users/settings"
    #  assert %{"error" => message} = flash
    #  assert message == "Email change link is invalid or it has expired."
    # end

    # No email in the setting
    # test "does not update email with invalid token", %{conn: conn, user: user} do
    #  {:error, redirect} = live(conn, ~p"/users/settings/confirm_email/oops")
    #  assert {:live_redirect, %{to: path, flash: flash}} = redirect
    #  assert path == ~p"/"
    #  assert %{"error" => message} = flash
    #  assert message == "Email change link is invalid or it has expired."
    #  assert Accounts.get_user_by_email(user.email)
    # end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      {:error, redirect} = live(conn, ~p"/users/settings/confirm_email/#{token}")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert %{"error" => message} = flash
      assert message == "You must log in to access this page."
    end
  end
end
