use Mix.Config

config :messages_router, MessagesRouter.RedisManager,
       database: "{$REDIS_NAME}",
       password: {:system, "REDIS_PASSWORD", nil},
       host: "{$REDIS_HOST}",
       port: "{$REDIS_PORT}",
       pool_size: "{$REDIS_POOL_SIZE}"


config :messages_router,
       mq_host:  "{$MQ_HOST}",
       mq_port:  "{$MQ_PORT}",
       resend_timeout: "{$MQ_RESEND_TIMEOUT}"