defmodule Radioapp.Seeds do

  # def test(tenant) do
  #   Radioapp.Seeds.RadioappTest.run(tenant)
  # end

  def dev(_tenant) do
    Radioapp.Seeds.RadioappDev.run("admin")
  end

  # def production(tenant) do
  #   Radioapp.Seeds.RadioappProd.run(tenant)
  # end

  def create_tenant(tenant) do
    case Triplex.create(tenant) do
      {:ok, _} ->
        IO.puts("Created tenant: #{tenant}")

      {:error, "ERROR 42P06" <> _} ->
        IO.puts("Tenant \"#{tenant}\" already exists")
    end

    Triplex.migrate(tenant)
  end
end