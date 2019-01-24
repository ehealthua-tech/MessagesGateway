use Mix.Config

config :vodafon_sms_protocol,  VodafonSmsProtocol.RedisManager,
       database: "${REDIS_NAME}",
       password: "${REDIS_PASSWORD}",
       host: "${REDIS_HOST}",
       port: "${REDIS_PORT}",
       pool_size: "${REDIS_POOL_SIZE}"
