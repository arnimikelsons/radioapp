defmodule RadioappWeb.SettingsHTML do
  use RadioappWeb, :html

  embed_templates "settings_html/*"

  @doc """
  Renders a settings form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def settings_form(assigns)
end
