use Mix.Config

# Configure your database
config :db_agent, DbAgent.Repo,
       adapter: Ecto.Adapters.Postgres,
       username: "postgres",
       password: "postgres",
       database: "messages_gateway",
       hostname: "localhost",
#       port: 5432,
       pool_size: 10

config :db_agent, elasticsearch_url: "http://192.168.100.165:9200"