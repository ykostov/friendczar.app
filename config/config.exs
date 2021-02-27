# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :friendczar,
  ecto_repos: [Friendczar.Repo]

# Configures the endpoint
config :friendczar, FriendczarWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "h9Ns5FXhMK3apkplqXO4JD79tUmTDxdCFIG6kd5bFBij9hbWPcPCFtMjIlFlw+uy",
  render_errors: [view: FriendczarWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Friendczar.PubSub,
  live_view: [signing_salt: "S6AUheRU"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
