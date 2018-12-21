defmodule ViberProtocol do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: ViberCallback, options: [port: 6012]),
      worker(ViberSubscriber, [])
    ]

    opts = [strategy: :one_for_one, name: ViberProtocol.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
