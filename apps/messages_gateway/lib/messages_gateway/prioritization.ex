defmodule MessagesGateway.Prioritization do
  @moduledoc false
  alias MessagesGateway.RedisManager

  @messages_gateway_conf "messages_gateway_conf"
  @operators_config "operators_config"
  @first_priority 1

  def get_priority_list() do
    with {:ok, messages_gateway_conf} <- RedisManager.get(@messages_gateway_conf),
        {:ok, operators_type_config} <- RedisManager.get(@operators_config),
        {:ok, priority} <- select_priority(Jason.decode!(operators_type_config), Map.get(Jason.decode!(messages_gateway_conf), "priority_model"), [])
      do
        {:ok, priority}
    end
  end

  def get_priority_list(operator_type_id) do
    with {:ok, operators_type_config} <- RedisManager.get(@operators_config) do
      {operator_type_id, operator_info_map} = List.keyfind(operators_type_config, operator_type_id, 0)
      {:ok, [%{
        operator_type_id: operator_type_id,
        priority: @first_priority,
        configs: operator_info_map.operator_configs}]}
    end
  end

  defp select_priority([], _, acc), do: acc
  defp select_priority([operator_type_map | tail], priority_key, acc) do
    [operator_type_id] = Map.keys(operator_type_map)
    operator_info_map = Map.get(operator_type_map, operator_type_id)
    priority = %{
      operator_type_id: operator_type_id,
      priority: Map.get(operator_info_map, priority_key),
      configs: Map.get(operator_info_map, @operators_config)}
    select_priority(tail, priority_key, [priority | acc])
  end

end
