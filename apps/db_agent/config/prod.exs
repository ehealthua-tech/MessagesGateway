use Mix.Config

config :db_agent, DbAgent.Repo,
       adapter: Ecto.Adapters.Postgres,
       database: System.get_env("DB_NAME"),
       username: System.get_env("DB_USER"),
       password: System.get_env("DB_PASSWORD"),
       hostname: System.get_env("DB_HOST"),
       port: System.get_env("DB_PORT") |> String.to_integer(),
       pool_size: System.get_env("DB_POOL_SIZE") |> String.to_integer(),
       timeout: 15_000,
       pool_timeout: 15_000