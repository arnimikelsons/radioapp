defmodule RadioappWeb.StationdefaultsHTML do
  use RadioappWeb, :html

  embed_templates "stationdefaults_html/*"

  @doc """
  Renders a stationdefaults form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def stationdefaults_form(assigns)
end
