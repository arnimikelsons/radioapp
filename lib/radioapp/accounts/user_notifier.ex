defmodule Radioapp.Accounts.UserNotifier do
  import Swoosh.Email

  alias Radioapp.{Mailer, Admin}

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

  def deliver_reset_password_instructions(user, tenant, url) do
    url = String.replace(url, "://", "://#{tenant}.")
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
    station_defaults = Admin.get_stationdefaults!(tenant)
    url = String.replace(url, "://", "://#{tenant}.")
    deliver(user.email, station_defaults.intro_email_subject, """

    ==============================

    Hi #{user.short_name},

    #{station_defaults.intro_email_body}

    #{url}
    
    Please contact #{station_defaults.support_email} if you have any questions.

    ==============================
    """)
  end

  def deliver_invited_to_tenant_email(user, tenant, url) do
    station_defaults = Admin.get_stationdefaults!(tenant)
    
    deliver(user.email, station_defaults.intro_email_subject, """

    ==============================

    Hi #{user.short_name},

    #{station_defaults.intro_email_body}

    #{url}

    Use your previous RadioApp email to log in. Please contact #{station_defaults.support_email} if you have any questions.

    ==============================
    """)
  end
end
