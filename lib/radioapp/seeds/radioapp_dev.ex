defmodule Radioapp.Seeds.RadioappDev do

  alias Radioapp.Accounts
  alias Radioapp.Admin

  # NOTE: Add email_confirmed_at to user changeset to seed working logins; remove after running
  def run(tenant) do
    Radioapp.Seeds.create_tenant(tenant)
    {:ok, _arni_admin} = Accounts.seeds_user(%{
      full_name: "Arni Mikelsons",
      short_name: "Arni",
      roles: %{tenant => "super_admin"},
      email: "arni@northernvillage.com",
      confirmed_at: DateTime.utc_now(),
      password: "super-secret",
      hashed_password: Bcrypt.hash_pwd_salt("super-secret"),
    })

    {:ok, _alice_admin} = Accounts.seeds_user(%{
      full_name: "Alice McExampleson",
      short_name: "Alice",
      confirmed_at: DateTime.utc_now(),
      email: "alice@example.com",
      roles: %{tenant => "admin"},
      password: "super-duper-secret",
      hashed_password: Bcrypt.hash_pwd_salt("super-secret"),
    })
    {:ok, _} = Admin.create_stationdefaults(
      %{
        callsign: "RadioApp",
        from_email: "radioapp@northernvillage.net",
        from_email_name: "RadioApp",
        logo_path: "/images/radioapp_logo.png",
        org_name: "radioApp",
        support_email: "radioapp@northernvillage.net",
        playout_type: "audio/mpeg",
        timezone: "Canada/Eastern",
        intro_email_subject: "Welcome to RadioApp: Website Management and Radio Logging Software",
        intro_email_body: "You are invited to join the Radioapp online App to manage your radio program."
      },
      tenant
    )




    # {:ok, _linda_admin} =
    #   Radioapp.Users.create_staff_user(
    #     %{
    #       email: "arni@northernvillage.com",
    #       password: "foobarbaz",
    #       password_confirmation: "foobarbaz",
    #       role: "admin",
    #       status: "Active",
    #       first_name: "Arni",
    #       last_name: "Mikelsons",
    #       email_confirmed_at: DateTime.utc_now()
    #     },
    #     tenant
    #   )

    # Enum.map(1..20, fn _ ->
    #   first_name = Faker.Person.first_name()
    #   last_name = Faker.Person.last_name()

    #   {:ok, user} =
    #     Radioapp.Users.create_worker_user(
    #       %{
    #         first_name: first_name,
    #         last_name: last_name,
    #         email: Faker.Internet.email(),
    #         password: "foobarbaz",
    #         password_confirmation: "foobarbaz",
    #         role: "worker",
    #         status: "New",
    #         terms_conditions: true,
    #         email_confirmed_at: DateTime.utc_now()
    #       },
    #       tenant
    #     )
  end
end
