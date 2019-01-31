use Mix.Config

config :db_agent, ecto_repos: [DbAgent.Repo]

import_config "/apps/db_agent/config/#{Mix.env}.exs"
