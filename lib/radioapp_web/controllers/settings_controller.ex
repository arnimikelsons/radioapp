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

  def show(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    settings = Admin.get_settings!(id, tenant)
    render(conn, :show, settings: settings)
  end

  def edit(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    settings = Admin.get_settings!(id, tenant)
    changeset = Admin.change_settings(settings)
    render(conn, :edit, settings: settings, changeset: changeset)
  end

  def update(conn, %{"id" => id, "settings" => settings_params}) do
    tenant = RadioappWeb.get_tenant(conn)
    settings = Admin.get_settings!(id, tenant)

    case Admin.update_settings(settings, settings_params) do
      {:ok, settings} ->
        conn
        |> put_flash(:info, "Settings updated successfully.")
        |> redirect(to: ~p"/settings/#{settings}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, settings: settings, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    settings = Admin.get_settings!(id, tenant)
    {:ok, _settings} = Admin.delete_settings(settings)

    conn
    |> put_flash(:info, "Settings deleted successfully.")
    |> redirect(to: ~p"/settings")
  end
end
