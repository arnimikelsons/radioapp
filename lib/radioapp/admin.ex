defmodule Radioapp.Admin do
  @moduledoc """
  The Admin context.
  """

  import Ecto.Query, warn: false
  alias Radioapp.Repo

  alias Radioapp.Admin.{Category, Link}

  @doc """
  Returns the list of links.

  ## Examples

      iex> list_links()
      [%Link{}, ...]

  """
  def list_links(tenant) do
    Repo.all(Link, prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Gets a single link.

  Raises `Ecto.NoResultsError` if the Link does not exist.

  ## Examples

      iex> get_link!(123)
      %Link{}

      iex> get_link!(456)
      ** (Ecto.NoResultsError)

  """

  def get_link!(id, tenant) do
    Repo.get!(Link, id, prefix: Triplex.to_prefix(tenant))
  end

  def list_links_dropdown(tenant) do
    links_query = from(l in Link, order_by: [asc: :type], select: {l.type, l.id})
    Repo.all(links_query, prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Creates a link.

  ## Examples

      iex> create_link(%{field: value})
      {:ok, %Link{}}

      iex> create_link(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_link(attrs \\ %{}, tenant) do
    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Updates a link.

  ## Examples

      iex> update_link(link, %{field: new_value})
      {:ok, %Link{}}

      iex> update_link(link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_link(%Link{} = link, attrs) do
    link
    |> Link.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a link.

  ## Examples

      iex> delete_link(link)
      {:ok, %Link{}}

      iex> delete_link(link)
      {:error, %Ecto.Changeset{}}

  """
  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking link changes.

  ## Examples

      iex> change_link(link)
      %Ecto.Changeset{data: %Link{}}

  """
  def change_link(%Link{} = link, attrs \\ %{}) do
    Link.changeset(link, attrs)
  end

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories(tenant) do
    from(p in Category, order_by: [asc: :code])
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:segments)
  end

  def list_categories_dropdown(tenant) do
    categories_query = from(c in Category, order_by: [asc: :code], select: {[c.code, "-", c.name], c.id})

    Repo.all(categories_query, prefix: Triplex.to_prefix(tenant))

  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id, tenant) do
    Category
    |> Repo.get!(id, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:segments) 
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}, tenant) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end


  alias Radioapp.Admin.Settings

  @doc """
  Returns the list of settings.

  ## Examples

      iex> list_settings()
      [%Settings{}, ...]

  """
  def list_settings(tenant) do
    Repo.all(Settings, prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Gets a single settings.

  Raises `Ecto.NoResultsError` if the Settings does not exist.

  ## Examples

      iex> get_settings!(123)
      %Settings{}

      iex> get_settings!(456)
      ** (Ecto.NoResultsError)

  """
  def get_settings!(tenant) do
    Repo.one(Settings, prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Creates a settings.

  ## Examples

      iex> create_settings(%{field: value})
      {:ok, %Settings{}}

      iex> create_settings(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_settings(attrs \\ %{}, tenant) do
    %Settings{}
    |> Settings.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Updates a settings.

  ## Examples

      iex> update_settings(settings, %{field: new_value})
      {:ok, %Settings{}}

      iex> update_settings(settings, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_settings(%Settings{} = settings, attrs) do
    settings
    |> Settings.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a settings.

  ## Examples

      iex> delete_settings(settings)
      {:ok, %Settings{}}

      iex> delete_settings(settings)
      {:error, %Ecto.Changeset{}}

  """
  def delete_settings(%Settings{} = settings) do
    Repo.delete(settings)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking settings changes.

  ## Examples

      iex> change_settings(settings)
      %Ecto.Changeset{data: %Settings{}}

  """
  def change_settings(%Settings{} = settings, attrs \\ %{}) do
    Settings.changeset(settings, attrs)
  end
end
