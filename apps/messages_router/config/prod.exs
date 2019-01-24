use Mix.Config


config :messages_router, MessagesRouter.RedisManager,
       database: "${REDIS_NAME}",
       password: "${REDIS_PASSWORD}",
       host: "${REDIS_HOST}",
       port: "${REDIS_PORT}",
       pool_size: "${REDIS_POOL_SIZE}"
