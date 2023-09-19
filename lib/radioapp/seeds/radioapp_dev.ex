defmodule Radioapp.Seeds.RadioappDev do

  alias Radioapp.Accounts

  # NOTE: Add email_confirmed_at to user changeset to seed working logins; remove after running
  def run(tenant) do
    Radioapp.Seeds.create_tenant(tenant)

    {:ok, _alice_admin} = Accounts.register_user(%{
      full_name: "Alice McExampleson",
      short_name: "Alice",
      confirmed_at: ~N[2000-01-01 23:00:07],
      email: "alice@example.com",
      role: "admin",
      password: "super-duper-secret",
      hashed_password: Bcrypt.hash_pwd_salt("super-duper-secret"),
      roles: %{tenant => "admin"}
    }) 

    {:ok, _arni_admin} = Accounts.register_user(%{
      full_name: "Arni Mikelsons",
      short_name: "Arni",
      role: "admin",
      email: "arni@northernvillage.com",
      confirmed_at: ~N[2000-01-01 23:00:07],
      password: "42Beach424242",
      hashed_password: Bcrypt.hash_pwd_salt("42Beach424242"),
      roles: %{tenant => "admin"}
    }) 

    OrganizationTenant.create(%{
      "tenant_name" => Id.admin_tenant(),
      "first_name" => "Some",
      "last_name" => "McUser",
      "organization" => "Access2ID Admin",
      "telephone" => "123-456-7890",
      "email" => "admin@access2id.ca"
    })
    
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
