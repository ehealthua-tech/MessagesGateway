use Mix.Releases.Config,
    default_release: :dev,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"&rS8o,Z*%Q[9VtA=LdOcb>vjk?8`K`Zm|xf.*MO?]d}v?=T;QwnY.e._.3<o1[NA"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"$FA/rA@uUX6fJ)cXN|Bb&Q)V&hH>]C%>0PA=ZE7:bAf[f?4$^N.lB@Y]9kXRqFl`"
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
    sms_router: :permanent,
    smtp_protocol: :permanent,
    telegram_protocol: :permanent,
    viber_protocol: :permanent,
    vodafon_sms_protocol: :permanent
  ]
end

