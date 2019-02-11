# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config


config :messages_router, MessagesRouter.MqManager,
       mq_host: "127.0.0.1",
       mq_port: "5672"


config :messages_router, MessagesRouter.RedisManager,
       host: "127.0.0.1",
       database: "2",
       password: nil,
       port: "6379",
       pool_size: "5"

