defmodule LifecellSmsProtocol.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
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
