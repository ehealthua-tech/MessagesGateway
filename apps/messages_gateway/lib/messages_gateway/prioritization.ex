defmodule MessagesGateway.Prioritization do
  @moduledoc false
  alias MessagesGateway.RedisManager

  @messages_gateway_conf "system_config"
  @operators_config "operators_config"
  @first_priority 1


  @spec get_message_priority_list() :: result when
          result: {:ok, {:error, any()} | MessagesGatewayInit.priority_list()}

  def get_message_priority_list() do
    with messages_gateway_conf <- RedisManager.get(@messages_gateway_conf),
        priority_list <- RedisManager.get(@operators_config)
      do
        {:ok, priority_list}
    end
  end

  @spec get_smtp_priority_list() :: result when
          result: {:ok,  {:error, any()} | MessagesGatewayInit.priority_list()}

  def get_smtp_priority_list() do
    with messages_gateway_conf <- RedisManager.get(@messages_gateway_conf),
         priority_list <- RedisManager.get(@operators_config)
      do
        {:ok, priority_list}
    end
  end

  @spec get_priority_list(protocol_name) :: result when
          protocol_name: String.t(),
          result: {:ok,  [nil] | [MessagesGatewayInit.priority_list()]}

  def get_priority_list(protocol_name) do
    with operators_type_config <- RedisManager.get(@operators_config) do
      {:ok, [Enum.find(operators_type_config, fn x -> x.protocol_name == protocol_name end)]}
    end
  end
end
