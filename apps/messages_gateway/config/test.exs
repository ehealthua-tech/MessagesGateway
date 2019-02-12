use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :messages_gateway, MessagesGatewayWeb.Endpoint,
  http: [port: 4001],
  server: false

config :messages_gateway, MessagesGateway.MqManager,
       mq_host: "127.0.0.1",
       mq_port: "5672"

config :messages_gateway, MessagesGateway.RedisManager,
       host: "127.0.0.1",
       database: "2",
       password: nil,
       port: "6379",
       pool_size: "5"

# Print only warnings and errors during test
config :logger, level: :warn

config :messages_gateway, MessagesGatewayWeb.KeysController,
       dets_file_name: :mydata_file_test
