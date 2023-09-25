defmodule Radioapp do
  @moduledoc """
  Radioapp keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  @spec admin_tenant() :: String.t()
  def admin_tenant() do
    Application.fetch_env!(:radioapp, :admin_tenant)
  end

  @spec super_admin_role() :: String.t()
  def super_admin_role() do
    Application.fetch_env!(:radioapp, :super_admin_role)
  end

  def cause_error(reason \\ "Boom") do
    raise reason
  end
end
