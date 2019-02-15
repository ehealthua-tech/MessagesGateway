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
  set dev_mode: true
  set include_erts: false

  set(
    overlays: [
      {:template, "rel/templates/vm.args.eex", "releases/<%= release_version %>/vm.args"}
    ]
  )
end

environment :prod do
  set include_erts: true
  set include_src: false

  set(
    overlays: [
      {:template, "rel/templates/vm.args.eex", "releases/<%= release_version %>/vm.args"}
    ]
  )
end

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

