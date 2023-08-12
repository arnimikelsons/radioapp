# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Radioapp.Repo.insert!(%Radioapp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

require Logger

case Radioapp.Accounts.register_user(%{
       full_name: "Alice McExampleson",
       short_name: "Alice",
       email: "alice@example.com",
       password: "super-duper-secret",
       role: "admin"
     }) do
  {:ok, user} ->
    user
    |> Radioapp.Accounts.User.confirm_changeset()
    |> Radioapp.Repo.update!()

  {:error, reason} ->
    Logger.warning(inspect(reason))
end
