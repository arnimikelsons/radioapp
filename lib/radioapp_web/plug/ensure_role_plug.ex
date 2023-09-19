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
  # alias Radioapp.Accounts.User
  alias Phoenix.Controller
  alias Plug.Conn

  @doc false
  @spec init(any()) :: any()
  def init(config), do: config

  @doc false
  @spec call(Conn.t(), atom() | [atom()]) :: Conn.t()
  def call(conn, target_role) do
    user_token = get_session(conn, :user_token)
    user = Accounts.get_user_by_session_token(user_token)
    tenant = conn.assigns.current_tenant

    conn
    |> Accounts.has_role?(user, target_role, tenant)
    |> maybe_halt(conn)

  end

  defp maybe_halt(true, conn), do: conn

  defp maybe_halt(_any, conn) do
    conn
    |> Controller.put_flash(:error, "Unauthorized access")
    |> Controller.redirect(to: signed_in_path(conn))
    |> Conn.halt()
  end

  defp signed_in_path(_conn), do: "/"


  # def call(conn, roles) do
  #   user_token = get_session(conn, :user_token)

  #   (user_token &&
  #      Accounts.get_user_by_session_token(user_token))
  #   |> has_role?(roles)
  #   |> maybe_halt(conn)
  # end

  # defp has_role?(%User{} = user, roles) when is_list(roles),
  #   do: Enum.any?(roles, &has_role?(user, &1))

  # defp has_role?(%User{role: role}, role), do: true
  # defp has_role?(_user, _role), do: false

  # defp maybe_halt(true, conn), do: conn

  # defp maybe_halt(_any, conn) do
  #   conn
  #   |> Controller.put_flash(:error, "Unauthorised")
  #   |> Controller.redirect(to: signed_in_path(conn))
  #   |> halt()
  # end

  # defp signed_in_path(_conn), do: "/"
end
