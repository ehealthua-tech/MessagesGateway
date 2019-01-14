defmodule LifecellSmsProtocol.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

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
    children = redis_workers ++ [
      worker(LifecellSmsProtocol, []),
      worker(LifecellSmsProtocol.MqManager, []),
      Plug.Cowboy.child_spec(scheme: :http, plug: LifecellSmsProtocol.LifecellSmsCallback, options: [port: 6014]),
      # Starts a worker by calling: LifecellSmsProtocol.Worker.start_link(arg)
      # {LifecellSmsProtocol.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LifecellSmsProtocol.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
