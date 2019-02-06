defmodule VodafonSmsProtocol.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  import Supervisor.Spec
  use Application

  @type spec() :: {child_id(), start_fun :: {module(), atom(), [term()]}, restart(), shutdown(), worker(), modules()}
  @type child_id() :: term()
  @type restart() :: :permanent | :transient | :temporary
  @type modules() :: :dynamic | [module()]
  @type shutdown() :: timeout() | :brutal_kill
  @type worker() :: :worker | :supervisor

  @spec start(type, args) :: result when
          type: atom(),
          args: :permanent | :transient | :temporary,
          result: {:ok, pid()} | {:ok, pid(), any()} | {:error, term()}

  def start(_type, _args) do
    redis_connects = create_redis_connects()
    # List all child processes to be supervised
    children = redis_connects ++ [
      worker(VodafonSmsProtocol, [])
      # Starts a worker by calling: VodafonSmsProtocol.Worker.start_link(arg)
      # {VodafonSmsProtocol.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VodafonSmsProtocol.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec create_redis_connects() :: [spec()]

  defp create_redis_connects() do
    config = Application.get_env(:vodafon_sms_protocol, VodafonSmsProtocol.RedisManager)
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
