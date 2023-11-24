defmodule RadioappWeb.Plug.InitializeStationdefaults do
  import Plug.Conn

  alias Radioapp.Admin

  def init(default), do: default

  def call(conn, _opts) do
    stationdefaults =
      conn
      |> RadioappWeb.get_tenant()
      |> Admin.get_stationdefaults!()

    conn
    |> put_private(:stationdefaults, stationdefaults)
    |> assign(:stationdefaults, stationdefaults)
  end
end