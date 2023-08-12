defmodule Radioapp.Repo do
  use Ecto.Repo,
    otp_app: :radioapp,
    adapter: Ecto.Adapters.Postgres
end
