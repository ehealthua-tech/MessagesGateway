use Mix.Config

# Configure your database
config :db_agent, DbAgent.Repo,
       adapter: Ecto.Adapters.Postgres,
       username: "savik",
       password: "savik",
       database: "messages_gateway",
       hostname: "192.168.100.165",
#       port: 5432,
       pool_size: 10