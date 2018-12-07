use Mix.Config

# Configure your database
config :db_agent, DbAgent.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "db_agent_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
