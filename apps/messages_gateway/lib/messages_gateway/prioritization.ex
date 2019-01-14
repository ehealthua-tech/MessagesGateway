defmodule MessagesGateway.Prioritization do
  @moduledoc false
  alias MessagesGateway.RedisManager

  @messages_gateway_conf "system_config"
  @operators_config "operators_config"
  @first_priority 1

  def get_priority_list() do
    with {:ok, messages_gateway_conf} <- RedisManager.get(@messages_gateway_conf),
        {:ok, priority_list} <- RedisManager.get(@operators_config)
      do
        {:ok, priority_list}
    end
  end

  def get_priority_list(protocol_name) do
    with {:ok, operators_type_config} <- RedisManager.get(@operators_config) do
      {:ok, Enum.find(operators_type_config, fn x -> x.protocol_name == protocol_name end)}
    end
  end
end
