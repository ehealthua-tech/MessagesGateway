# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :viber_protocol,
       auth_token: "48f01d9268e7d064-5c8b70def6243721-a025fd7b15cb0902"

config :viber_protocol,  ViberProtocol.RedisManager,
       host: "127.0.0.1",
       database: "2",
       password: nil,
       port: "6379",
       pool_size: "5"

config :viber_protocol,
       callback_port: "6012"

config :viber_protocol,
       viber_endpoint: TestEndpoint