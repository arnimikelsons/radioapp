defmodule RadioappWeb.Plugs.Subdomain do
  import Plug.Conn

  @doc false
  def init(default), do: default

  @doc false
  def call(conn, _router) do
    case get_subdomain(conn.host) do
      subdomain when byte_size(subdomain) > 0 ->
        conn
        |> put_private(:subdomain, subdomain)
        |> assign(:current_tenant, subdomain)

      _ ->
        conn
    end
  end

  defp get_subdomain(host) do
    host
    |> String.split(".")
    |> List.first()
  end
  # @behaviour Plug # see this for more on behaviours: https://elixir-lang.org/getting-started/typespecs-and-behaviours.html#behaviours

  # import Plug.Conn

  # def init(_opts) do
  #   %{ root_host: RadioappWeb.Endpoint.config(:url)[:host] }
  # end

  # def call(%Plug.Conn{host: host} = conn, %{root_host: root_host} = _opts) do
  #   case extract_subdomain(host, root_host) do
  #     subdomain when byte_size(subdomain) > 0 ->
  #       conn
  #       |> put_private(:subdomain, subdomain)
  #       |> assign(:current_tenant, subdomain)
  #     _ ->
  #       conn
  #   end
  # end

  # defp extract_subdomain(host, root_host) do
  #   #String.replace(host, ~r/.?#{root_host}/, "")
  #   host
  #   |> String.split(".")
  #   |> List.first()
  # end
end