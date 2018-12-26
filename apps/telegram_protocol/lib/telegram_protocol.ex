defmodule TelegramProtocol do
    use Application

    def start(_type, _args) do
      import Supervisor.Spec

      children = [
        worker(TelegramSubscriber, []),
        worker(TelegramApi, [])
      ]

      opts = [strategy: :one_for_one, name: TelegramProtocol.Supervisor]
      Supervisor.start_link(children, opts)
    end

  end
