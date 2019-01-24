defmodule SmsRouter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    config = Application.get_env(:sms_router,  SmsRouter.RedisManager)
    hostname = config[:host]
    password = config[:password]
    database = config[:database]
    port = config[:port]

    redis_workers = for i <- 6..(config[:pool_size] + 5) do
      worker(Redix,
        ["redis://#{password}@#{hostname}:#{port}/#{database}",
          [name: :"redis_#{i}"]
        ],
        id: {Redix, i}
      )
    end
    children = [
    worker(SmsRouter.MqManager, []) | redis_workers
      # Starts a worker by calling: SmsRouter.Worker.start_link(arg)
      # {SmsRouter.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SmsRouter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
