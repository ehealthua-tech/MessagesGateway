defmodule SmsRouter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    config = Application.get_env(:sms_router,  SmsRouter.RedisManager)
    hostname = config[:host]
    password = config[:password]
    database = config[:database]
    port = config[:port]
    pool_size =  String.to_integer(config[:pool_size])
    children  = for i <- 0..(pool_size - 1) do
      worker(Redix,
        ["redis://#{password}@#{hostname}:#{port}/#{database}",
          [name: :"redis_#{i}"]
        ],
        id: {Redix, i}
      )
    end
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SmsRouter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end