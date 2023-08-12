defmodule RadioappWeb.AllowIFramePlug do
  import Plug.Conn

  def init(opts) do
    opts
  end

  @url "https://cfrc.editmy.website"
  def call(conn, _opts) do
    conn
    |> put_resp_header("x-frame-options", "allow-from #{@url}")
    |> put_resp_header("content-security-policy", "frame-ancestors #{@url};")
  end
end
