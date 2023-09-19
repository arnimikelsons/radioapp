defmodule Radioapp.Accounts.UserNotifier do
  import Swoosh.Email

  alias Radioapp.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Radioapp", "radioapp@northernvillage.net"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end


  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
  def deliver_invitation_instructions(user, tenant, url) do
    url = String.replace(url, "://", "://#{tenant}.")
    deliver(user.email, "Invitation to Radio App", """

    ==============================

    Hi #{user.email},

    You are invited to join the CFRC online App to manage your radio program. Click on the following link to join:

    #{url}

    Please contact <a href="mailto:radioapp@northernvillage.net">radioapp@northernvillage.net</a> if you have any questions.

    ==============================
    """)
  end

  def deliver_invited_to_tenant_email(user, url) do

    deliver(user.email, "Invitation to Radio App", """

    ==============================

    Hi #{user.email},

    You are invited to join the CFRC online App to manage your radio program. Click on the following link to join:

    #{url}

    Please contact <a href="mailto:radioapp@northernvillage.net">radioapp@northernvillage.net</a> if you have any questions.

    ==============================
    """)
  end
end
