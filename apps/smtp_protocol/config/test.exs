# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :smtp_protocol, SmtpProtocol.Mailer,
       adapter: Bamboo.SMTPAdapter,
       server: "smtp.office365.com",
       hostname: "skywell.software",
       port: 587,
       username: "r.moroz@skywell.software", # or {:system, "SMTP_USERNAME"}
       password: "Gembird1nser%", # or {:system, "SMTP_PASSWORD"}
       tls: :if_available, # can be `:always` or `:never`
       allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"], # or {:system, "ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
       ssl: false, # can be `true`
       retries: 1,
       no_mx_lookups: false, # can be `true`
       auth: :if_available # can be `always`. If your smtp relay requires authentication set it to `always`.

config :smtp_protocol, SmtpProtocol.RedisManager,
       host: "127.0.0.1",
       database: "1",
       password: nil,
       port: "6379",
       pool_size: "5"
