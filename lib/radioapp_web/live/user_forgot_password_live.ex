defmodule RadioappWeb.UserForgotPasswordLive do
  use RadioappWeb, :live_view

  alias Radioapp.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Forgot your password?
        <:subtitle>We'll send a password reset link to your inbox</:subtitle>
      </.header>

      <.simple_form :let={f} id="reset_password_form" for={%{}} as={:user} phx-submit="send_email">
        <.input field={{f, :email}} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full">
            Send password reset instructions
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end     

  def mount(_params, %{"subdomain" => tenant}, socket) do
    socket =
      socket
      |> assign(:tenant, tenant)

    {:ok, socket}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    tenant = socket.assigns.tenant

    # TODO: get user by email AND tenant and don't send emails on tenants
    # That the user is not part of.kkj
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        tenant,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
