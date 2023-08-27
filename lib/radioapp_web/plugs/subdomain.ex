defmodule RadioappWeb.Plugs.Subdomain do

  @behaviour Plug # see this for more on behaviours: https://elixir-lang.org/getting-started/typespecs-and-behaviours.html#behaviours

  import Plug.Conn

  def init(opts) do
    %{ root_host: RadioappWeb.Endpoint.config(:url)[:host] }
  end

  def call(%Plug.Conn{host: host} = conn, %{root_host: root_host} = opts) do
    case extract_subdomain(host) do
      subdomain when byte_size(subdomain) > 0 ->
        conn
        |> put_private(:subdomain, subdomain)
        |> assign(:current_tenant, subdomain)
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