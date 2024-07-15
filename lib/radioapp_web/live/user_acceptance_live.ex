defmodule RadioappWeb.UserAcceptanceLive do
  use RadioappWeb, :live_view

  alias Radioapp.Accounts

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <.header>Confirm Account</.header>
    <p>
      Hello <%= @user.full_name %> (<%= @user.short_name %>), please select your password and confirm your account.
    </p>

    <.simple_form
      :let={f}
      for={@changeset}
      id="confirmation_form"
      phx-submit="confirm_account"
      phx-change="validate"
    >
      <.input field={{f, :token}} type="hidden" value={@token} />
      <.input field={{f, :password}} type="password" label="Password" required />
      <.input field={{f, :password_confirmation}} type="password" label="Confirm Password" required />
      <:actions>
        <.button phx-disable-with="Confirming...">Confirm my account</.button>
      </:actions>
    </.simple_form>

    <%!-- <p>
      <.link href={~p"/users/log_in"}>Log in</.link>
    </p> --%>
    """
  end

  # def mount(params, _session, socket) do
  #  {:ok, assign(socket, token: params["token"]), temporary_assigns: [token: nil]}
  # end

  def mount(params, _session, socket) do
    socket = assign_user_and_token(socket, params)

    socket =
      case socket.assigns do
        %{user: user} ->
          socket
          |> assign(:changeset, Accounts.change_accept_user(user))

        _ ->
          socket
      end

    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_accept_user(user_params)
      |> Map.put(:action, :validation)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def handle_event("confirm_account", %{"user" => %{"token" => token} = user_params}, socket) do
    user = socket.assigns.user

    case Accounts.accept_user(user, token, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Your account is now active.")
         |> redirect(to: ~p"/")}

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "User confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Accounts.get_user_by_confirm_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end
end
