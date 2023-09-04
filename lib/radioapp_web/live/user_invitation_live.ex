defmodule RadioappWeb.UserInvitationLive do
  use RadioappWeb, :live_view

  alias Radioapp.Accounts
  alias Radioapp.Accounts.User
  import RadioappWeb.LiveHelpers

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Send invitation for an account
      </.header>

      <.simple_form
        :let={f}
        id="invitation_form"
        for={@changeset}
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/"}
        method="get"
        as={:user}
      >
        <.error :if={@changeset.action == :insert}>
          Oops, something went wrong! Please check the errors below.
        </.error>
        <.input field={{f, :password}} type="hidden" value={@password}/>
        <.input field={{f, :password_confirmation}} type="hidden" value={@password}/>
        <.input field={{f, :full_name}} type="text" label="Full Name" required />
        <.input field={{f, :short_name}} type="text" label="Short Name" required />
        <.input field={{f, :email}} type="email" label="Email" required />
        <.input field={{f, :tenant_role}} options={([user: "user", admin: "admin"])} type="select" label="Role" required />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, session, socket) do
    tenant = Map.fetch!(session, "subdomain")
    socket =
      assign_defaults(session, socket)

    changeset = Accounts.change_user_invitation(%User{})
    socket = assign(socket, changeset: changeset, trigger_submit: false)
    password = "ABCD928374982696"
    {:ok, socket, temporary_assigns: [changeset: nil, password: password, tenant: tenant]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    tenant = socket.assigns.tenant
    tenant_role = user_params["tenant_role"]
    case Accounts.invite_user_for_tenant(user_params, tenant_role, tenant) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_invitation_instructions(
            user,
            &url(~p"/users/accept/#{&1}")
          )

        changeset = Accounts.change_user_invitation(user)
        {:noreply, assign(socket, trigger_submit: true, changeset: changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end
end
