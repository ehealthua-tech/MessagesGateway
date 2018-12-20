# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :viber_protocol, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:viber_protocol, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env()}.exs"

config :messages_router,
       namespace: MessagesRouter,
       mq_host: "localhost",
       mq_port: 5672

config :viber_protocol,
       auth_token: "48f01d9268e7d064-5c8b70def6243721-a025fd7b15cb0902"