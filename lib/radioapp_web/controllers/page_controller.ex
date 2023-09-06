defmodule RadioappWeb.PageController do
  use RadioappWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def archives(conn, _params) do
    render(conn, :archives)
  end

  def podcasts(conn, _params) do
    render(conn, :podcasts)
  end

  def admin(conn, _params) do
    user = conn.assigns.current_user
    tenant = conn.assigns.current_tenant
    user_role = Map.get(user.roles, tenant)

    render(conn, :admin, user_role: user_role)
  end

end
