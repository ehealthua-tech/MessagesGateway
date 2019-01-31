use Mix.Config

config :lifecell_ip_telephony_protocol, LifecellIpTelephonyProtocol.RedisManager,
       database: System.get_env("REDIS_NAME"),
       password: System.get_env("REDIS_PASSWORD"),
       host: System.get_env("REDIS_HOST"),
       port: System.get_env("REDIS_PORT") |> String.to_integer(),
       pool_size: System.get_env("REDIS_POOL_SIZE") |> String.to_integer()

config :ex_ami,
       servers: [
              {:asterisk, [
                     {:connection, {ExAmi.TcpConnection, [
                            {:host,  System.get_env("ASTERISK_HOST")}, {:port, System.get_env("ASTERISK_PORT") |> String.to_integer() }
                     ]}},
                     {:username,  System.get_env("ASTERISK_USERNAME")},
                     {:secret,  System.get_env("ASTERISK_PASSWORD")}
              ]} ]

