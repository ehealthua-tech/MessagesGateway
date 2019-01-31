use Mix.Config

config :smtp_protocol, SmtpProtocol.RedisManager,
       database: System.get_env("REDIS_NAME"),
       password: System.get_env("REDIS_PASSWORD"),
       host: System.get_env("REDIS_HOST"),
       port: System.get_env("REDIS_PORT") |> String.to_integer(),
       pool_size: System.get_env("REDIS_POOL_SIZE") |> String.to_integer()