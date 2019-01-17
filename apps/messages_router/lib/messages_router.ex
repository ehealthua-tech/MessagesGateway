defmodule MessagesRouter do
  use Application

  @spec start(:normal | {:takeover, atom()} | {:failover, atom()}, start_args :: term()) ::
          {:ok, pid()} | {:ok, pid(), term()} | {:error, reason :: term()}
  def start(_type, _args) do
    import Supervisor.Spec
    config = Application.get_env(:telegram_protocol, TelegramProtocol.RedisManager)
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
    children = redis_workers ++[
      worker(MessagesRouter.MqManager, []) #|  redis_workers
    ]

    opts = [strategy: :one_for_one, name: MessagesRouter.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
