defmodule SystemConfigController do
  @moduledoc false

  use MessagesGatewayWeb, :controller
  action_fallback(MessagesGatewayWeb.FallbackController)

  @messages_gateway_conf :messages_gateway_conf
  @operators_config :operators_config

  #  ---- send a message to the client any available way ------------------------

  def show(conn, _params) do
    with {:ok, system_config} <- RedisManager.get(@messages_gateway_conf)
      do
        render(conn, "system_config.json",  %{:config => system_config})
    end

  end

  #  ---- send a message to the client any available way ------------------------

  def add(conn, %{"resource" => %{"auth" => auth, "password" => password}}) do
    with :ok <- RedisManager.set(@messages_gateway_conf)
      do
        render(conn, "change_system_config.json", %{status: :ok})
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
