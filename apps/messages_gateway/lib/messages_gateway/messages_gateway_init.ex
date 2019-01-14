defmodule MessagesGatewayInit do
  @moduledoc false
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    pool_size = Application.get_env(:messages_gateway,  MessagesGateway.RedisManager)[:pool_size]
    connection_index = rem(System.unique_integer([:positive]), pool_size)
    Redix.command(:"redis_#{connection_index}", ["SET", "sys_config", ""])
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
