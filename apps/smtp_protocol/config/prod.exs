use Mix.Config

config :smtp_protocol, SmtpProtocol.RedisManager,
       database: "${REDIS_NAME}",
       password: System.get_env("REDIS_PASSWORD"),
       host: "${REDIS_HOST}",
       port: "${REDIS_PORT}",
       pool_size: "${REDIS_POOL_SIZE}",
       host: "${REDIS_HOST}",
       port: "${REDIS_PORT}",
       pool_size: "${REDIS_POOL_SIZE}"

config :smtp_protocol, SmtpProtocol.RedisManager,
       adapter: Bamboo.SMTPAdapter,
       server: "${SMTP_SERVER}",
       hostname: "${SMTP_HOSTNAME}",
       port: 587,
       username: "${SMTP_USERNAME}",
       password: "${SMTP_PASSWORD}",
       tls: :if_available, # can be `:always` or `:never`
       allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"], # or {:system, "ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
       ssl: false, # can be `true`
       retries: 1,
       no_mx_lookups: false, # can be `true`
       auth: :if_available

