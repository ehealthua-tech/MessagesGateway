use Mix.Config

config :db_agent, ecto_repos: [DbAgent.Repo]

import_config "#{Mix.env}.exs"
