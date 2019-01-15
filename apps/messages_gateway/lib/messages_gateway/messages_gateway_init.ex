defmodule MessagesGatewayInit do
  @moduledoc false
  use GenServer
  alias MessagesGateway.RedisManager
  alias DbAgent.OperatorsRequests

  @messages_gateway_conf "system_config"
  @operators_config "operators_config"
  @sys_config %{"default_sms_operator" => "" }

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    RedisManager.set(@messages_gateway_conf, @sys_config)
    RedisManager.set(@operators_config,  create_operators_list_to_redis())
    {:ok, []}
  end

  def handle_info(msg, state) do
    {:noreply, state}
  end

  def terminate(_reason, %{conn: conn}) do
    Connection.close(conn)
    :ok
  end

  defp create_operators_list_to_redis() do
    OperatorsRequests.list_operators()
    |> create_priority_list([])
  end

  defp create_priority_list([], acc), do: acc
  defp create_priority_list([operator_config_map | tail], acc) do
    priority = %{
      protocol_name: operator_config_map.operator.protocol_name,
      priority: operator_config_map.operator_type.priority,
      operator_priority: operator_config_map.operator.priority,
      configs: operator_config_map.operator.config,
      limit: operator_config_map.operator.limit,
      active_protocol_type: operator_config_map.operator_type.active,
      active: operator_config_map.operator.active}
    create_priority_list(tail, [priority | acc])
  end


end
