defmodule SmtpProtocol.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    config = Application.get_env(:smtp_protocol, SmtpProtocol.RedisManager)
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
    children = redis_workers ++
               [
                 worker(SmtpProtocol, [])
               ]

    opts = [strategy: :one_for_one, name: SmtpProtocol.Supervisor]
    Supervisor.start_link(children, opts)
  end
end