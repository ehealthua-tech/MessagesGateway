defmodule ViberProtocol do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(ViberSubscriber, [])
    ]

    opts = [strategy: :one_for_one, name: ViberProtocol.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
