use Mix.Config

config :viber_protocol, ViberProtocol.RedisManager,
       database: "${REDIS_NAME}",
       password: System.get_env("REDIS_PASSWORD"),
       host: "${REDIS_HOST}",
       port: "${REDIS_PORT}",
       pool_size: "${REDIS_POOL_SIZE}"


config :viber_protocol,
       callback_port: "${VIBER_CALLBACK_PORT}"

config :viber_protocol,
       viber_endpoint: ViberEndpoint