use Mix.Config


config :lifecell_ip_telephony_protocol,  LifecellIpTelephonyProtocol.RedisManager,
       database: "${REDIS_NAME}",
       password: "${REDIS_PASSWORD}",
       host: "${REDIS_HOST}",
       port: "${REDIS_PORT}",
       pool_size: "${REDIS_POOL_SIZE}"
