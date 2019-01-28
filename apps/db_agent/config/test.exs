use Mix.Config

# Configure your database
config :db_agent, DbAgent.Repo,
       adapter: Ecto.Adapters.Postgres,
       username: "savik",
       password: "savik",
       database: "messages_gateway_test",
       hostname: "192.168.100.165",
       pool_size: 10,
       pool: Ecto.Adapters.SQL.Sandbox