defmodule LifecellIpTelephonyProtocol.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  import Supervisor.Spec
  use Application

  def start(_type, _args) do
    redis_connects = create_redis_connects()
    # List all child processes to be supervised
    children = redis_connects ++ [
      worker(LifecellIpTelephonyProtocol.MqManager, []),
      worker(LifecellIpTelephonyProtocol, [])
      # Starts a worker by calling: LifecellIpTelephonyProtocol.Worker.start_link(arg)
      # {LifecellIpTelephonyProtocol.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LifecellIpTelephonyProtocol.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp create_redis_connects() do
    config = Application.get_env(:lifecell_ip_telephony_protocol, LifecellIpTelephonyProtocol.RedisManager)
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
  end
end
