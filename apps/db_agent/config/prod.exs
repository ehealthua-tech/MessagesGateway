use Mix.Config

config :db_agent, DbAgent.Repo,
       adapter: Ecto.Adapters.Postgres,
       database: "${DB_NAME}",
       username: "${DB_USER}",
       password: "${DB_PASSWORD}",
       hostname: "${DB_HOST}",
       port: "${DB_PORT}",
       pool_size: "${DB_POOL_SIZE}",
       timeout: 15_000,
       pool_timeout: 15_000
