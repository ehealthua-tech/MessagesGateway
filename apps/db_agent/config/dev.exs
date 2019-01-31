use Mix.Config

# Configure your database
config :db_agent, DbAgent.Repo,
       adapter: Ecto.Adapters.Postgres,
       username: "postgres",
       password: "postgres",
       database: "messages_gateway",
       hostname: "localhost",
       pool_size: 10