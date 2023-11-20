defmodule RadioappWeb.Plug.InitializeSettings do
  import Plug.Conn

  alias Radioapp.Admin

  def init(default), do: default

  def call(conn, _opts) do
    settings =
      conn
      |> RadioappWeb.get_tenant()
      |> Admin.get_settings!()

    conn
    |> put_private(:settings, settings)
    |> assign(:settings, settings)
  end
end