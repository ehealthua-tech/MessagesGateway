use Mix.Config


config :lifecell_sms_protocol, LifecellSmsProtocol.RedisManager,
       database: "${REDIS_NAME}",
       password: System.get_env("REDIS_PASSWORD"),
       host: "${REDIS_HOST}",
       port: "${REDIS_PORT}",
       pool_size: "${REDIS_POOL_SIZE}"

config :lifecell_sms_protocol,
       callback_port: "${LIFECELL_CALLBACK_PORT}"

config :lifecell_sms_protocol,
       endpoint: EndpointManager