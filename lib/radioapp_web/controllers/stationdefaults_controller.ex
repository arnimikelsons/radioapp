defmodule RadioappWeb.StationdefaultsController do
  use RadioappWeb, :controller

  alias Radioapp.Admin
  alias Radioapp.Admin.Stationdefaults

  def index(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    stationdefaults = Admin.list_stationdefaults(tenant)
    render(conn, :index, stationdefaults: stationdefaults)
  end

  def new(conn, _params) do
    changeset = Admin.change_stationdefaults(%Stationdefaults{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"stationdefaults" => stationdefaults_params}) do
    tenant = RadioappWeb.get_tenant(conn)

    case Admin.create_stationdefaults(stationdefaults_params, tenant) do
      {:ok, stationdefaults} ->
        conn
        |> put_flash(:info, "Station defaults created successfully.")
        |> redirect(to: ~p"/stationdefaults/#{stationdefaults}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{}) do
    tenant = RadioappWeb.get_tenant(conn)
    stationdefaults = Admin.get_stationdefaults!(tenant)
    render(conn, :show, stationdefaults: stationdefaults)
  end

  def edit(conn, %{}) do
    tenant = RadioappWeb.get_tenant(conn)
    stationdefaults = Admin.get_stationdefaults!(tenant)
      if stationdefaults == nil do
        {:ok, _stationdefaults} =
          Admin.create_stationdefaults(
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
    stationdefaults = Admin.get_stationdefaults!(tenant)
    changeset = Admin.change_stationdefaults(stationdefaults)
    timezones = Tzdata.zone_list()

    render(conn, :edit, stationdefaults: stationdefaults, changeset: changeset, timezones: timezones)
  end

  def update(conn, %{"stationdefaults" => stationdefaults_params}) do
    tenant = RadioappWeb.get_tenant(conn)
    stationdefaults = Admin.get_stationdefaults!(tenant)

    case Admin.update_stationdefaults(stationdefaults, stationdefaults_params) do
      {:ok, stationdefaults} ->
        conn
        |> put_flash(:info, "Station defaults updated successfully.")
        |> redirect(to: ~p"/stationdefaults/#{stationdefaults}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, stationdefaults: stationdefaults, changeset: changeset)
    end
  end

  def delete(conn, %{}) do
    tenant = RadioappWeb.get_tenant(conn)
    stationdefaults = Admin.get_stationdefaults!(tenant)
    {:ok, _stationdefaults} = Admin.delete_stationdefaults(stationdefaults)

    conn
    |> put_flash(:info, "Station defaults deleted successfully.")
    |> redirect(to: ~p"/stationdefaults")
  end
end
