use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :messages_gateway, MessagesGatewayWeb.Endpoint,
  http: [port: 4011],
  debug_errors: false,
  code_reloader: true,
  check_origin: false,
  render_errors: [view: EView.Views.PhoenixError, accepts: ~w(json)],
  watchers: []

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :messages_gateway, MessagesGateway.MqManager,
       mq_host: "127.0.0.1",
       mq_port: 5672

config :messages_gateway, MessagesGateway.RedisManager,
       host: "127.0.0.1",
       database: "1",
       password: nil,
       port: 6379,
       pool_size: 5

config :messages_gateway, MessagesGatewayWeb.KeysController,
       dets_file_name: :mydata_file