use Mix.Config

config :messages_router, MessagesRouter.RedisManager,
       database: System.get_env("REDIS_NAME"),
       password: System.get_env("REDIS_PASSWORD"),
       host: System.get_env("REDIS_HOST"),
       port: System.get_env("REDIS_PORT") |> String.to_integer(),
       pool_size: System.get_env("REDIS_POOL_SIZE") |> String.to_integer()


config :messages_router,
       namespace: System.get_env("MQ_NAMESPACE"),
       mq_host:  System.get_env("MQ_HOST"),
       mq_port:  System.get_env( "MQ_PORT") |> String.to_integer(),
       resend_timeout: System.get_env("MQ_RESEND_TIMEOUT") |> String.to_integer()