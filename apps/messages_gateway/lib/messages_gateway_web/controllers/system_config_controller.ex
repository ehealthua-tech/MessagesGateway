defmodule MessagesGatewayWeb.SystemConfigController do
  @moduledoc false
  alias MessagesGateway.RedisManager

  use MessagesGatewayWeb, :controller
  action_fallback(MessagesGatewayWeb.FallbackController)

  @messages_gateway_conf "system_config"
  @operators_config :operators_config

  #  ---- send a message to the client any available way ------------------------

  def index(conn, _params) do
    with system_config <- RedisManager.get(@messages_gateway_conf)
      do
      render(conn, "index.json",  %{:config => system_config})
    end
  end

  #  ---- send a message to the client any available way ------------------------

  def edit(conn, %{"resource" => %{"auth" => auth, "password" => password}}) do
    with {:ok, system_config} <- RedisManager.set(@messages_gateway_conf)
      do
        render(conn, "change_system_config.json", %{status: :ok})
    end

  end
end
