# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :liveview_test,
  ecto_repos: [LiveviewTest.Repo]

# Configures the endpoint
config :liveview_test, LiveviewTestWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tA4LqIFXGVfIuOxc0wXfxMSHsA/B86WKlJAACAUVv42uWvmvn4gB8P/NlCuZNAN5",
  render_errors: [view: LiveviewTestWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: LiveviewTest.PubSub,
  live_view: [signing_salt: "yTZcFqpG"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
