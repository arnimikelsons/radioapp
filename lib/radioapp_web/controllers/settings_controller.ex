defmodule RadioappWeb.SettingsController do
  use RadioappWeb, :controller

  alias Radioapp.Admin
  alias Radioapp.Admin.Settings

  def index(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    settings = Admin.list_settings(tenant)
    render(conn, :index, settings: settings)
  end

  def new(conn, _params) do
    changeset = Admin.change_settings(%Settings{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"settings" => settings_params}) do
    tenant = RadioappWeb.get_tenant(conn)

    case Admin.create_settings(settings_params, tenant) do
      {:ok, settings} ->
        conn
        |> put_flash(:info, "Settings created successfully.")
        |> redirect(to: ~p"/settings/#{settings}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{}) do
    tenant = RadioappWeb.get_tenant(conn)
    settings = Admin.get_settings!(tenant)
    render(conn, :show, settings: settings)
  end

  def edit(conn, %{}) do
    tenant = RadioappWeb.get_tenant(conn)
    settings = Admin.get_settings!(tenant) 
      if settings == nil do
        {:ok, _settings} =
          Admin.create_settings(
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
    settings = Admin.get_settings!(tenant)
    changeset = Admin.change_settings(settings)
    render(conn, :edit, settings: settings, changeset: changeset)
  end

  def update(conn, %{"settings" => settings_params}) do
    tenant = RadioappWeb.get_tenant(conn)
    settings = Admin.get_settings!(tenant)

    case Admin.update_settings(settings, settings_params) do
      {:ok, settings} ->
        conn
        |> put_flash(:info, "Settings updated successfully.")
        |> redirect(to: ~p"/settings/#{settings}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, settings: settings, changeset: changeset)
    end
  end

  def delete(conn, %{}) do
    tenant = RadioappWeb.get_tenant(conn)
    settings = Admin.get_settings!(tenant)
    {:ok, _settings} = Admin.delete_settings(settings)

    conn
    |> put_flash(:info, "Settings deleted successfully.")
    |> redirect(to: ~p"/settings")
  end
end
