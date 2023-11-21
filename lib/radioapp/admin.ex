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


  alias Radioapp.Admin.Defaults

  @doc """
  Returns the list of defaults.

  ## Examples

      iex> list_defaults()
      [%Defaults{}, ...]

  """
  def list_defaults(tenant) do
    Repo.all(Defaults, prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Gets a single defaults.

  Raises `Ecto.NoResultsError` if the Defaults does not exist.

  ## Examples

      iex> get_defaults!(123)
      %Defaults{}

      iex> get_defaults!(456)
      ** (Ecto.NoResultsError)

  """
  def get_defaults!(tenant) do
    Repo.one(Defaults, prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Creates a defaults.

  ## Examples

      iex> create_defaults(%{field: value})
      {:ok, %Defaults{}}

      iex> create_defaults(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_defaults(attrs \\ %{}, tenant) do
    %Defaults{}
    |> Defaults.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  @doc """
  Updates a defaults.

  ## Examples

      iex> update_defaults(defaults, %{field: new_value})
      {:ok, %Defaults{}}

      iex> update_defaults(defaults, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_defaults(%Defaults{} = defaults, attrs) do
    defaults
    |> Defaults.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a defaults.

  ## Examples

      iex> delete_defaults(defaults)
      {:ok, %Defaults{}}

      iex> delete_defaults(defaults)
      {:error, %Ecto.Changeset{}}

  """
  def delete_defaults(%Defaults{} = defaults) do
    Repo.delete(defaults)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking defaults changes.

  ## Examples

      iex> change_defaults(defaults)
      %Ecto.Changeset{data: %Defaults{}}

  """
  def change_defaults(%Defaults{} = defaults, attrs \\ %{}) do
    Defaults.changeset(defaults, attrs)
  end
end
