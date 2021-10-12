defmodule LiveviewTest.Repo do
  use Ecto.Repo,
    otp_app: :liveview_test,
    adapter: Ecto.Adapters.Postgres
end
