defmodule Radioapp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Radioapp.Repo
  alias Radioapp.Accounts.{User, UserToken, UserNotifier, Org, OrganizationTenant}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user_in_tenant!(user_id, tenant) do
    User
    |> in_tenant?(tenant)
    |> Repo.get(user_id)
  end

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def seeds_user(attrs) do
    %User{}
    |> User.seeds_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  def change_user_invitation(%User{} = user, attrs \\ %{}) do
    User.invitation_changeset_for_tenant(user, attrs, hash_password: false, validate_email: false)
  end

  # def invite_user(attrs) do
  #   %User{}
  #   |> User.invitation_changeset_for_tenant(attrs)
  #   |> Repo.insert()
  # end

  def invite_user_for_tenant(attrs, role, tenant) do
    changeset = %User{}
    |> User.invitation_changeset_for_tenant(attrs)
    |> Ecto.Changeset.change(roles: %{tenant => role})

    create_or_add_user_role_for_tenant(changeset, role, tenant)
  end

  def create_or_add_user_role_for_tenant(changeset, role, tenant) do
    case Repo.insert(changeset) do
      {:ok, user} ->
        {:new_user_created, user}

      {:error, %{errors: errors} = reason} ->
        case Keyword.get(errors, :email) do
          {"has already been taken", _} ->
            result =
              Repo.transaction(fn ->
                # find the existing user by the email given
                email = Ecto.Changeset.fetch_field!(changeset, :email)
                user = get_user_by_email(email)
                # add the new tenant and role to the existing roles
                roles = user.roles |> Map.put(tenant, role)

                # update only the user's roles
                user
                |> Ecto.Changeset.change(%{roles: roles})
                |> Repo.update!()
              end)

            case result do
              {:ok, user} -> {:user_added_to_tenant, user}
              {:error, reason} -> {:error, reason}
            end

          _ ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end


  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  def change_user_name(user, attrs \\ %{}) do
    User.name_changeset(user, attrs)
  end

  def edit_user(user, attrs \\ %{}) do
    User.edit_changeset(user, attrs)
  end

  # def update_user(%User{} = user, attrs) do
  #   user
  #   |> User.edit_changeset(attrs)
  #   |> Repo.update()
  # end

  def update_user_in_tenant(%User{} = user, attrs, tenant_role, tenant) do
    roles = user.roles |> Map.put(tenant, tenant_role)

    user
    |> User.edit_changeset(attrs)
    |> Ecto.Changeset.change(%{roles: roles})
    |> Repo.update()
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end


  def update_user_name(user, password, attrs) do
    user
    |> User.name_changeset(attrs)
    |> User.validate_current_password(password)
    |> Repo.update()
  end


  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
        {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

        Repo.insert!(user_token)
        UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex>  (user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
  when is_function(confirmation_url_fun, 1) do
      if user.confirmed_at do
        {:error, :already_confirmed}
      else
        {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
        Repo.insert!(user_token)
        UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
      end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
  end

  def change_accept_user(user, attrs \\ %{}) do
    User.accept_changeset(user, attrs, hash_password: false)
  end


  def accept_user(_user, token, attrs) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
          %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(accept_user_multi(user, attrs)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp accept_user_multi(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.accept_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
  end

  def deliver_user_invitation_instructions(%User{} = user, tenant, invitation_url_fun)
  when is_function(invitation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_invitation_instructions(user, tenant, invitation_url_fun.(encoded_token))
    end
  end


  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  def get_user_by_confirm_token(token) do
    with {:ok, query} <- UserToken.confirm_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
      end
    
  end

  @doc """
  Returns the list of users.
  ## Examples
      iex> list_users()
      [%User{}, ...]
  """
  def list_users(tenant) do

    from(p in User, order_by: [asc: :email])
    |> in_tenant?(tenant)
    |> Repo.all()
  end

    @doc """
  Deletes a user.
  ## Examples
      iex> delete_user(user)
      {:ok, %Category{}}
      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def has_role?(conn, user, role, tenant) when is_atom(role) do
    has_role?(conn, user, Atom.to_string(role), tenant)
  end

  def has_role?(_conn, nil, _, _), do: false

  def has_role?(conn, user, roles, tenant) when is_list(roles) do
    roles |> Enum.any?(fn role -> has_role?(conn, user, role, tenant) end)
  end

  def has_role?(_conn, user, role, tenant) when is_binary(role) do
    roles = Map.get(user, :roles, %{})
    Map.get(roles, tenant, %{}) == role
  end


  @doc """
  Returns the list of orgs.

  ## Examples

      iex> list_orgs()
      [%Org{}, ...]

  """
  def list_orgs do
    Repo.all(Org)
  end

  @doc """
  Gets a single org.

  Raises `Ecto.NoResultsError` if the Org does not exist.

  ## Examples

      iex> get_org!(123)
      %Org{}

      iex> get_org!(456)
      ** (Ecto.NoResultsError)

  """
  def get_org!(id), do: Repo.get!(Org, id)

  @doc """
  Creates a org.

  ## Examples

      iex> create_org(%{field: value})
      {:ok, %Org{}}

      iex> create_org(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_org(attrs \\ %{}) do
    %Org{}
    |> Org.changeset(attrs)
    |> Repo.insert()
  end

  def initialize_org(%{} = attrs) do
    OrganizationTenant.create(attrs)
  end

  @doc """
  Updates a org.

  ## Examples

      iex> update_org(org, %{field: new_value})
      {:ok, %Org{}}

      iex> update_org(org, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_org(%Org{} = org, attrs) do
    org
    |> Org.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a org.

  ## Examples

      iex> delete_org(org)
      {:ok, %Org{}}

      iex> delete_org(org)
      {:error, %Ecto.Changeset{}}

  """
  def delete_org(%Org{} = org) do
    Repo.delete(org)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking org changes.

  ## Examples

      iex> change_org(org)
      %Ecto.Changeset{data: %Org{}}

  """
  def change_org(%Org{} = org, attrs \\ %{}) do
    Org.changeset(org, attrs)
  end

  def in_tenant?(user_query, tenant) do
    user_query
    |> where([u], fragment("roles->>? is not null", ^tenant))
  end

end
