use Mix.Releases.Config,
    default_release: :dev,
    default_environment: Mix.env()


# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  # If you are running Phoenix, you should make sure that
  # server: true is set and the code reloader is disabled,
  # even in dev mode.
  # It is recommended that you build with MIX_ENV=prod and pass
  # the --env flag to Distillery explicitly if you want to use
  # dev mode.
  set dev_mode: true
  set include_erts: false
  set cookie: :"b;vW=AJE.nBa@l{Dw.x6mH:)67a8S5{_7a]dXn7uc`;B{~Cnm1%XA5V9j)k!;G$f"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :";6WdzzI;},727{8krOe;cEjIH0lw,L49KUiupZdTh$pEz78ngl?J!ZIy|M.)c[Y@"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :messages_gateway_api do
  set version: "0.1.0"
  set applications: [
    :runtime_tools,
    db_agent: :permanent,
    lifecell_ip_telephony_protocol: :permanent,
    lifecell_sms_protocol: :permanent,
    messages_gateway: :permanent,
    messages_router: :permanent,
    mg_logger: :permanent,
    sms_router: :permanent,
    smtp_protocol: :permanent,
    telegram_protocol: :permanent,
    viber_protocol: :permanent,
    vodafon_sms_protocol: :permanent
  ]
end

