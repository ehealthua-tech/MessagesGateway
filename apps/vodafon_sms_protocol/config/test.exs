# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :vodafon_sms_protocol,  VodafonSmsProtocol.RedisManager,
       host: "127.0.0.1",
       database: "1",
       password: nil,
       port: 6379,
       pool_size: 5