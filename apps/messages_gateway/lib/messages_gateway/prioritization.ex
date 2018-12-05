defmodule MessagesGateway.Prioritization do
  @moduledoc false
  alias MessagesGateway.Redis

  @messages_gateway_conf :messages_gateway_conf
  @priority_on_price :priority_on_price
  @priority_on_rang :priority_on_rang
  @operators_config :operators_config
  @first_priority 1

  def message_prioritization() do
    with {:ok, priority_model} <- Redis.get(@messages_gateway_conf),
        {:ok, operators_type_config} <- Redis.get(@operators_config),
        {:ok, priority} <- select_priority(operators_type_config, priority_model, [])
      do
        {:ok, priority}
    end
  end

  def message_prioritization(operator_type_id) do
    with {:ok, operators_type_config} <- Redis.get(@operators_config) do
      {operator_type_id, operator_info_map} = List.keyfind(operators_type_config, operator_type_id, 0)
      {:ok, [%{
        operator_type_id: operator_type_id,
        priority: @first_priority,
        configs: operator_info_map.operator_configs}]}
    end
  end

  defp select_priority([], priority_key, acc), do: acc
  defp select_priority([{operator_type_id, operator_info_map} | tail], priority_key, acc) do
    priority = %{
      operator_type_id: operator_type_id,
      priority: Map.get(operator_info_map, priority_key),
      configs: operator_info_map.operator_configs}
    select_priority([head | tail], priority_key, [priority | acc])
  end

end
