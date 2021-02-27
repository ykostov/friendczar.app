defmodule Friendczar.Repo do
  use Ecto.Repo,
    otp_app: :friendczar,
    adapter: Ecto.Adapters.Postgres
end
