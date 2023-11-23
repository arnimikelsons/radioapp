defmodule RadioappWeb.DefaultsController do
  use RadioappWeb, :controller

  alias Radioapp.Admin
  alias Radioapp.Admin.Defaults

  def index(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    defaults = Admin.list_defaults(tenant)
    render(conn, :index, defaults: defaults)
  end

  def new(conn, _params) do
    changeset = Admin.change_defaults(%Defaults{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"defaults" => defaults_params}) do
    tenant = RadioappWeb.get_tenant(conn)

    case Admin.create_defaults(defaults_params, tenant) do
      {:ok, defaults} ->
        conn
        |> put_flash(:info, "Defaults created successfully.")
        |> redirect(to: ~p"/defaults/#{defaults}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{}) do
    tenant = RadioappWeb.get_tenant(conn)
    defaults = Admin.get_defaults!(tenant)
    render(conn, :show, defaults: defaults)
  end

  def edit(conn, %{}) do
    tenant = RadioappWeb.get_tenant(conn)
    defaults = Admin.get_defaults!(tenant) 
      if defaults == nil do
        {:ok, _defaults} =
          Admin.create_defaults(
            %{
              callsign: tenant,
              from_email: "radioapp@northernvillage.net",
              from_email_name: "RadioApp",
              org_name: tenant,
              logo_path: "/images/radioapp_logo.png"
            },
            tenant
          )   
    end
    defaults = Admin.get_defaults!(tenant)
    changeset = Admin.change_defaults(defaults)
    render(conn, :edit, defaults: defaults, changeset: changeset)
  end

  def update(conn, %{"defaults" => defaults_params}) do
    tenant = RadioappWeb.get_tenant(conn)
    defaults = Admin.get_defaults!(tenant)

    case Admin.update_defaults(defaults, defaults_params) do
      {:ok, defaults} ->
        conn
        |> put_flash(:info, "Defaults updated successfully.")
        |> redirect(to: ~p"/defaults/#{defaults}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, defaults: defaults, changeset: changeset)
    end
  end

  def delete(conn, %{}) do
    tenant = RadioappWeb.get_tenant(conn)
    defaults = Admin.get_defaults!(tenant)
    {:ok, _defaults} = Admin.delete_defaults(defaults)

    conn
    |> put_flash(:info, "Defaults deleted successfully.")
    |> redirect(to: ~p"/defaults")
  end
end
