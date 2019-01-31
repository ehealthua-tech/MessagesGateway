use Mix.Config


config :lifecell_sms_protocol, LifecellSmsProtocol.RedisManager,
       database: System.get_env("REDIS_NAME"),
       password: System.get_env("REDIS_PASSWORD"),
       host: System.get_env("REDIS_HOST"),
       port: System.get_env("REDIS_PORT") |> String.to_integer(),
       pool_size: System.get_env("REDIS_POOL_SIZE") |> String.to_integer()

