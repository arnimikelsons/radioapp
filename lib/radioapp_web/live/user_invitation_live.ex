defmodule RadioappWeb.UserInvitationLive do
  use RadioappWeb, :live_view

  alias Radioapp.Accounts
  alias Radioapp.Accounts.{User, UserNotifier}
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
        
        <%= if @tenant == Radioapp.admin_tenant() do %>
          <.input field={{f, :tenant_role}} options={([super_admin: "super_admin"])} type="select" label="Role" required />
        <% else %>
          <.input field={{f, :tenant_role}} options={([user: "user", admin: "admin"])} type="select" label="Role" required />
        <% end %>
        
        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, session, socket) do
    tenant = Map.fetch!(session, "subdomain")
    host = Map.fetch!(session, "host")
    socket =
      assign_defaults(session, socket)
      |> assign(:host, host)


    changeset = Accounts.change_user_invitation(%User{})
    socket = assign(socket, changeset: changeset, trigger_submit: false)
    password = "ABCD928374982696"
    {:ok, socket, temporary_assigns: [changeset: nil, password: password, tenant: tenant]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    tenant = socket.assigns.tenant
    host = socket.assigns.host
    host = String.replace(host, ".fly.dev", ".ca")
    tenant_role = user_params["tenant_role"]
    case Accounts.invite_user_for_tenant(user_params, tenant_role, tenant) do
      {:new_user_created, user} ->
        {:ok, _} =
          Accounts.deliver_user_invitation_instructions(
            user,
            tenant,
            &url(~p"/users/accept/#{&1}")
          )

        changeset = Accounts.change_user_invitation(user)
        {:noreply, assign(socket, trigger_submit: true, changeset: changeset)}


      {:user_added_to_tenant, user} ->
        if user.confirmed_at do
          url = "https://#{host}"
          {:ok, _} = UserNotifier.deliver_invited_to_tenant_email(user, url)
        else 
          Accounts.deliver_user_invitation_instructions(
            user,
            tenant,
            &url(~p"/users/accept/#{&1}")
          )
        end
        
        changeset = Accounts.change_user_invitation(user)
        {:noreply, assign(socket, trigger_submit: true, changeset: changeset)}
      
      {:error, "User exists in tenant"} ->
        {:noreply,
        socket
        |> put_flash(:error, "User exists in tenant.")
        |> redirect(to: ~p"/users")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}


      # {:ok, user} ->
      #   {:ok, _} =
      #     Accounts.deliver_user_invitation_instructions(
      #       user,
      #       &url(~p"/users/accept/#{&1}")
      #     )

      #   changeset = Accounts.change_user_invitation(user)
      #   {:noreply, assign(socket, trigger_submit: true, changeset: changeset)}

      # {:error, %Ecto.Changeset{} = changeset} ->
      #   {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end
end
