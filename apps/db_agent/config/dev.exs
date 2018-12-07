use Mix.Config

# Configure your database
config :db_agent, DbAgent.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "db_agent_dev",
  hostname: "localhost",
  pool_size: 10
