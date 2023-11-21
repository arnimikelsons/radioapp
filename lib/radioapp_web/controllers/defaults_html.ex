defmodule RadioappWeb.DefaultsHTML do
  use RadioappWeb, :html

  embed_templates "defaults_html/*"

  @doc """
  Renders a defaults form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def defaults_form(assigns)
end
