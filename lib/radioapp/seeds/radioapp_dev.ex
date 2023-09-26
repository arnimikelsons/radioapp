defmodule Radioapp.Seeds.RadioappDev do

  alias Radioapp.Accounts
  alias Radioapp.Accounts.OrganizationTenant

  # NOTE: Add email_confirmed_at to user changeset to seed working logins; remove after running
  def run(tenant) do
    Radioapp.Seeds.create_tenant(tenant)
IO.inspect(tenant, label: "TENANT")
    {:ok, _arni_admin} = Accounts.seeds_user(%{
      full_name: "Arni Mikelsons",
      short_name: "Arni",
      roles: %{tenant => "admin"},
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
