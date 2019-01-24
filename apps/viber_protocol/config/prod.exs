use Mix.Config

config :viber_protocol,  ViberProtocol.RedisManager,
       database: "${REDIS_NAME}",
       password: "${REDIS_PASSWORD}",
       host: "${REDIS_HOST}",
       port: "${REDIS_PORT}",
       pool_size: "${REDIS_POOL_SIZE}"
