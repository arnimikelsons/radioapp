defmodule RadioappWeb.Plugs.Subdomain do
  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    opts
  end

  def call(%Plug.Conn{host: host} = conn, _opts) do
    case extract_subdomain(host) do
      subdomain when byte_size(subdomain) > 0 ->
        conn
        |> put_private(:subdomain, subdomain)
        |> assign(:current_tenant, subdomain)
        |> assign(:host, host)

      _ ->
        conn
    end
  end

  defp extract_subdomain(host) do
    host
    |> String.split(".")
    |> List.first()
  end
end
