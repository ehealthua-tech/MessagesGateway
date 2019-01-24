use Mix.Config


config :smtp_protocol, SmtpProtocol.RedisManager,
       database: "${REDIS_NAME}",
       password: "${REDIS_PASSWORD}",
       host: "${REDIS_HOST}",
       port: "${REDIS_PORT}",
       pool_size: "${REDIS_POOL_SIZE}"
