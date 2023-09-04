defmodule RadioappWeb.UserController do
  use RadioappWeb, :controller

  alias Radioapp.Accounts

  def index(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    users = Accounts.list_users()
    render(conn, :index, users: users, tenant: tenant)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    tenant = RadioappWeb.get_tenant(conn)
    
    tenant_role = user.roles[tenant]

    if tenant_role != nil do
      changeset =
        Accounts.edit_user(user)
        |> Ecto.Changeset.put_change(:tenant_role, tenant_role)

      render(conn, :edit, user: user, changeset: changeset)
    else
      if user.role != nil do
        tenant_role = user.role
        changeset =
          Accounts.edit_user(user)
          |> Ecto.Changeset.put_change(:tenant_role, tenant_role)
        
          render(conn, :edit, user: user, changeset: changeset)
      else 
        conn
        |> put_flash(:error, "User not found")
        |> redirect(to: ~p"/users")
      end
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)
    tenant = RadioappWeb.get_tenant(conn)
    tenant_role = user_params["tenant_role"]

    case Accounts.update_user_in_tenant(user, user_params, tenant_role, tenant) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: ~p"/users")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, user: user, tenant_role: tenant_role, changeset: changeset)
    end

  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: ~p"/users")
  end
end
