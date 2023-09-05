defmodule RadioappWeb.EnsureRolePlug do
  @moduledoc """
  This plug ensures that a user has a particular role before accessing a given route.
  ## Example
  Let's suppose we have three roles: :admin, :manager and :user.
  If you want a user to have at least manager role, so admins and managers are authorised to access a given route
  plug RealEstateWeb.EnsureRolePlug, [:admin, :manager]
  If you want to give access only to an admin:
  plug RealEstateWeb.EnsureRolePlug, :admin
  """
  import Plug.Conn

  alias Radioapp.Accounts
  alias Radioapp.Accounts.User
  alias Phoenix.Controller
  alias Plug.Conn

  @doc false
  @spec init(any()) :: any()
  def init(config), do: config

  @doc false
  @spec call(Conn.t(), atom() | [atom()]) :: Conn.t()
  def call(conn, _opts) do
    user_token = get_session(conn, :user_token)
    user = Accounts.get_user_by_session_token(user_token)
    tenant = conn.assigns.current_tenant

    case user do
      %User{roles: roles} ->
        case Map.get(roles, tenant) do
          "admin" ->
            conn
          "user" ->
            conn  
          _ -> 
            conn
              |> Controller.put_flash(:error, "Unauthorised")
              |> Controller.redirect(to: signed_in_path(conn))
              |> halt()
        end
        _ ->
          conn
          |> Controller.put_flash(:error, "Unauthorised")
          |> Controller.redirect(to: signed_in_path(conn))
          |> halt()
    end
  end

  defp signed_in_path(_conn), do: "/"
end
