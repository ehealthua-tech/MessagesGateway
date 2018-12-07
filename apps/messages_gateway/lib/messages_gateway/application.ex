defmodule MessagesGateway.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @spec start(Application.start_type(), list) :: Supervisor.on_start()
  def start(_type, _args) do
    import Supervisor.Spec

    config = Application.get_env(:messages_gateway,  MessagesGateway.RedisManager)
    hostname = config[:host]
    password = config[:password]
    database = config[:database]
    port = config[:port]

    redis_workers = for i <- 0..(config[:pool_size] - 1) do
      worker(Redix,
        ["redis://#{password}@#{hostname}:#{port}/#{database}",
          [name: :"redis_#{i}"]
        ],
        id: {Redix, i}
      )
    end
    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(MessagesGatewayWeb.Endpoint, []),
      worker(MessagesGateway.MqPublisher, []) |  redis_workers
      # mq = MessagesGatewayWeb.MqPublisher
      # Start your own worker by calling: MessagesGateway.Worker.start_link(arg1, arg2, arg3)
      # worker(MessagesGateway.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MessagesGateway.Supervisor]
    Supervisor.start_link(children, opts)

  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MessagesGatewayWeb.Endpoint.config_change(changed, removed)
    :ok
  end

end
