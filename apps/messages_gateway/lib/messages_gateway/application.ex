defmodule MessagesGateway.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @spec start(type, args) :: result when
          type: Application.start_type(),
          args: list,
          result: {:ok, pid()} | {:error, {:already_started, pid()} | {:shutdown, term()} | term()}

  def start(_type, _args) do
    import Supervisor.Spec

    config = Application.get_env(:messages_gateway,  MessagesGateway.RedisManager)
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
    # Define workers and child supervisors to be supervised
    children = redis_workers ++ [
      supervisor(MessagesGatewayWeb.Endpoint, []),
      worker(MessagesGateway.MqManager, []),
      worker(MessagesGatewayInit, [])
    ]

    opts = [strategy: :one_for_one, name: MessagesGateway.Supervisor]
    Supervisor.start_link(children, opts)

  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @spec config_change(changed, new, removed) :: result when
          changed: keyword(),
          new: keyword(),
          removed: [atom()],
          result: :ok

  def config_change(changed, _new, removed) do
    MessagesGatewayWeb.Endpoint.config_change(changed, removed)
    :ok
  end

end
