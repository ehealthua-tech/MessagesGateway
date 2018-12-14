defmodule MessagesRouter do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

#    config = Application.get_env(:messages_router,  MessagesRouter.Redis)
#    hostname = config[:host]
#    password = config[:password]
#    database = config[:database]
#    port = config[:port]
#
#    redis_workers = for i <- 0..(config[:pool_size] - 1) do
#      worker(Redix,
#        ["redis://#{password}@#{hostname}:#{port}/#{database}",
#          [name: :"redis_#{i}"]
#        ],
#        id: {Redix, i}
#      )
#    end

    children = [
      worker(MqSubscriber, []) #|  redis_workers
    ]

    opts = [strategy: :one_for_one, name: MessagesRouter.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
