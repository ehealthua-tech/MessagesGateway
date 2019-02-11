defmodule MessagesGatewayWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :messages_gateway

  if Application.get_env(:messages_gateway, :sql_sandbox) do
    plug(Phoenix.Ecto.SQL.Sandbox)
  end

  plug(Plug.RequestId)
  plug(EView.Plugs.Idempotency)
  plug(Plug.LoggerJSON, level: Logger.level())

  plug(EView)

  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_messages_gateway_key",
    signing_salt: "gYhQTGy/"

  plug MessagesGatewayWeb.Router

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    :io.format("~nload_from_system_env: ~p~n", [config[:load_from_system_env]])
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      :io.format("~nport: ~p~n", [port])
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      :io.format("~nconfig: ~p~n", [config])
      {:ok, config}

    end

  end
end
