defmodule MessagesGatewayInit do
  @moduledoc false
  use GenServer
  alias MessagesGateway.RedisManager

  @messages_gateway_conf "system_config"
  @sys_config %{"default_sms_operator" => "" }

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    RedisManager.set(@messages_gateway_conf, @sys_config)
    {:ok, []}
  end

  def handle_info(msg, state) do
    {:noreply, state}
  end

  def terminate(_reason, %{conn: conn}) do
    Connection.close(conn)
    :ok
  end

end
