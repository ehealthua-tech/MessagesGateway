defmodule ViberProtocol.Application do
  use Application

  @spec start(type, args) :: result when
          type: atom(),
          args: :permanent | :transient | :temporary,
          result: {:ok, pid()} | {:ok, pid(), any()} | {:error, term()}

  def start(_type, _args) do
    import Supervisor.Spec
    config = Application.get_env(:viber_protocol, ViberProtocol.RedisManager)
    hostname = config[:host]
    password = config[:password]
    database = config[:database]
    port = config[:port]
    pool_size =  String.to_integer(config[:pool_size])
    {:ok, app_name} = :application.get_application(__MODULE__)

    redis_workers = for i <- 0..(pool_size - 1) do
      worker(Redix,
        ["redis://#{password}@#{hostname}:#{port}/#{database}",
          [name: :"redis_#{Atom.to_string(app_name)}_#{i}"]
        ],
        id: {Redix, i}
      )
    end
    callback_port = String.to_integer(Application.get_env(:viber_protocol, :callback_port))
    children = redis_workers ++
      [
        worker(ViberProtocol, []),
        Plug.Cowboy.child_spec(scheme: :http, plug: ViberCallback, options: [port: callback_port])
      ]

    opts = [strategy: :one_for_one, name: ViberProtocol.Supervisor]
    Supervisor.start_link(children, opts)
  end
end