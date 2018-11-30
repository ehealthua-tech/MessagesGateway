use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()


environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"<q,AMYB_3CK56<?p7TQr(Jzc~J/&ADBbBb:$kFE@D3u8.<e@G3;p]UAR3h7?u3hq"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"l>ecV?Tl?`[=PAnjCTTVXYbx(v0NE?%f5T]!9^KSQAbUvD{nZUhV7!y~r{I8X4%F"
  set vm_args: "rel/vm.args"
end

environment :test do
  set include_erts: true
  set include_src: false
  set cookie: :";W^JBe|r10%%>?@&Y8XgVeZwH9kJ?w?bO/bl1!gjiD(P.<;2IkIz,[o<Mox:<.qg"
end

release :messages_gateway do
  set version: "0.1.0"
  set applications: [
    :runtime_tools,
      messages_gatewat: :permanent
  ]
end

