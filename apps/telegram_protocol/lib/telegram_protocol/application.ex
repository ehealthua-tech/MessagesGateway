defmodule TelegramProtocol.Application do
  use Application

  @spec start(type, args) :: result when
          type: atom(),
          args: :permanent | :transient | :temporary,
          result: {:ok, pid()} | {:ok, pid(), any()} | {:error, term()}

  def start(_type, _args) do
    import Supervisor.Spec
    config = Application.get_env(:telegram_protocol, TelegramProtocol.RedisManager)
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
    children = redis_workers ++
      [
        worker(TelegramProtocol, [])
      ]

    opts = [strategy: :one_for_one, name: TelegramProtocol.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
