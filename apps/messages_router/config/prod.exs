use Mix.Config

config :messages_router, MessagesRouter.RedisManager,
       database: "${REDIS_NAME}",
       password: System.get_env("REDIS_PASSWORD"),
       host: "${REDIS_HOST}",
       port: "${REDIS_PORT}",
       pool_size: "${REDIS_POOL_SIZE}"


config :messages_router,  MessagesRouter.MqManager,
       mq_modul: MessagesGateway.MqManager,
       mq_host:  "${MQ_HOST}",
       mq_port:  "${MQ_PORT}",
       resend_timeout: "{$MQ_RESEND_TIMEOUT}",
       mq_queue:  "${MQ_QUEUE}",
       mq_exchange: "${MQ_EXCHANGE}"