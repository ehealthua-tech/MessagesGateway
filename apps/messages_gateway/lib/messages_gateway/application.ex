defmodule MessagesGateway.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(MessagesGatewayWeb.Endpoint, []),
      worker(MessagesGateway.MqPublisher, []) |  redis_workers()
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

  @spec redis_workers :: list
  def redis_workers() do
    redis_config = Application.get_env(:messages_gateway,  MessagesGateway.Redis)

    Enum.map(0..(redis_config[:pool_size] - 1), fn connection_index ->
      worker(
        Redix,
        [
          [
            host: redis_config[:host],
            port: redis_config[:port],
            password: redis_config[:password],
            database: redis_config[:database]
          ],
          [name: :"redis_#{connection_index}"]
        ],
        id: {Redix, connection_index}
      )
    end)
  end
end
