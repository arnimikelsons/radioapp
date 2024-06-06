defmodule RadioappWeb.UserController do
  use RadioappWeb, :controller

  alias Radioapp.Accounts

  def index(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    users = Accounts.list_users(tenant)
    current_user = conn.assigns.current_user
    user_role = 
      if Map.get(current_user.roles, tenant) == nil do
        Map.get(current_user.roles, "admin")
      else 
        Map.get(current_user.roles, tenant)
      end
    render(conn, :index, users: users, tenant: tenant, user_role: user_role)
  end

  def edit(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    user = Accounts.get_user_in_tenant!(id, tenant)
    tenant = RadioappWeb.get_tenant(conn)
    
    tenant_role = user.roles[tenant]

    if tenant_role != nil do
      changeset =
        Accounts.edit_user(user)
        |> Ecto.Changeset.put_change(:tenant_role, tenant_role)

      render(conn, :edit, user: user, changeset: changeset, tenant: tenant)
    else
      if user.role != nil do
        tenant_role = user.role
        changeset =
          Accounts.edit_user(user)
          |> Ecto.Changeset.put_change(:tenant_role, tenant_role)
        
          render(conn, :edit, user: user, changeset: changeset, tenant: tenant)
      else 
        conn
        |> put_flash(:error, "User not found")
        |> redirect(to: ~p"/users")
      end
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    tenant = RadioappWeb.get_tenant(conn)

    user = Accounts.get_user_in_tenant!(id, tenant)
    tenant_role = user_params["tenant_role"]
    case Accounts.update_user_in_tenant(user, user_params, tenant_role, tenant) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: ~p"/users")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, user: user, tenant: tenant, changeset: changeset)
    end

  end

  def delete(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    user = Accounts.get_user_in_tenant!(id, tenant)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: ~p"/users")
  end
end
