use Mix.Config

config :lifecell_ip_telephony_protocol, LifecellIpTelephonyProtocol.RedisManager,
       database: "${REDIS_NAME}",
       password: System.get_env("REDIS_PASSWORD"),
       host: "${REDIS_HOST}",
       port: "${REDIS_PORT}",
       pool_size: "${REDIS_POOL_SIZE}"

config :ex_ami,
       servers: [
              {:asterisk, [
                     {:connection, {ExAmi.TcpConnection, [
                            {:host,  "${ASTERISK_HOST}"}, {:port, "${ASTERISK_PORT}" }
                     ]}},
                     {:username,  "${ASTERISK_USERNAME}"},
                     {:secret,  "${ASTERISK_PASSWORD}"}
              ]} ]

