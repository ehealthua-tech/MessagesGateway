use Mix.Config

config :telegram_protocol, TelegramProtocol.RedisManager,
       database: "${REDIS_NAME}",
       password: System.get_env("REDIS_PASSWORD"),
       host: "${REDIS_HOST}",
       port: "${REDIS_PORT}",
       pool_size: "${REDIS_POOL_SIZE}"

config :telegram_protocol, TelegramProtocol,
       telegram_driver: TDLib

config :tdlib, backend_binary: "/messages_gateway_api/lib/tdlib-0.0.2/priv/tdlib-json-cli"
