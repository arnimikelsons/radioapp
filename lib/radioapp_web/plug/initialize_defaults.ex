defmodule RadioappWeb.Plug.InitializeDefaults do
  import Plug.Conn

  alias Radioapp.Admin

  def init(default), do: default

  def call(conn, _opts) do
    defaults =
      conn
      |> RadioappWeb.get_tenant()
      |> Admin.get_defaults!()

    conn
    |> put_private(:defaults, defaults)
    |> assign(:defaults, defaults)
  end
end