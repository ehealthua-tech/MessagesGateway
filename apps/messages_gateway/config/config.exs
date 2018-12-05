# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :messages_gateway,
  namespace: MessagesGateway,
  mq_host: "localhost",
  mq_port: 5672

# Configures the endpoint
config :messages_gateway, MessagesGatewayWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "MEmTh3fnaarKBXe3uAOUepRVcfXNXjOwUXDly0LThcwAIMwFoHLo3sSHLfRz3h+B",
  render_errors: [view: MessagesGatewayWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MessagesGateway.PubSub,
           adapter: Phoenix.PubSub.PG2]


# Configures Elixir's Logger
config :logger, :console,
       format: "$time $metadata[$level] $message\n",
       metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
