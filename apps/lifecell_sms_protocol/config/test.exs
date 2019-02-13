# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :lifecell_sms_protocol,
       sms_send_url: "http://bulk.bs-group.com.ua/clients.php",
       login: "test",
       password: "test"

config :lifecell_sms_protocol,  LifecellSmsProtocol.RedisManager,
       host: "127.0.0.1",
       database: "1",
       password: nil,
       port: "6379",
       pool_size: "5"

config :lifecell_sms_protocol,
       callback_port: "6016"