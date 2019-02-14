
use Mix.Config

config :ex_ami,
       servers: [
         {:asterisk, [
           {:connection, {ExAmi.TcpConnection, [
             {:host, "127.0.0.1"}, {:port, 5038}
           ]}},
           {:username, "elixirconf"},
           {:secret, "elixirconf"}
         ]} ]


config :lifecell_ip_telephony_protocol,  LifecellIpTelephonyProtocol.RedisManager,
       host: "127.0.0.1",
       database: "2",
       password: nil,
       port: "6379",
       pool_size: "5"
