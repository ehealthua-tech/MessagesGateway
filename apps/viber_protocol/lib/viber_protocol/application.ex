defmodule ViberProtocol.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    config = Application.get_env(:viber_protocol, ViberProtocol.RedisManager)
    hostname = config[:host]
    password = config[:password]
    database = config[:database]
    port = config[:port]
    {:ok, app_name} = :application.get_application(__MODULE__)
    redis_workers = for i <- 0..(config[:pool_size] - 1) do
      worker(Redix,
        ["redis://#{password}@#{hostname}:#{port}/#{database}",
          [name: :"redis_#{Atom.to_string(app_name)}_#{i}"]
        ],
        id: {Redix, i}
      )
    end
    children = redis_workers ++
      [
        worker(ViberProtocol, []),
        Plug.Cowboy.child_spec(scheme: :http, plug: ViberCallback, options: [port: 6013]),
        worker(ViberProtocol.MqManager, [])
      ]

    opts = [strategy: :one_for_one, name: ViberProtocol.Supervisor]
    Supervisor.start_link(children, opts)
  end
end