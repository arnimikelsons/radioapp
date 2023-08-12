defmodule RadioappWeb.LiveHelpers do
  use RadioappWeb, :live_view

  alias Radioapp.Accounts
  alias Radioapp.Accounts.User

  def assign_defaults(session, socket) do
    socket =
      socket
      |> assign_new(:current_user, fn ->
        find_current_user(session)
      end)

    socket
  end

  defp find_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token),
         do: user
  end

end