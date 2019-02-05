defmodule MessagesGateway.Prioritization do
  @moduledoc false
  alias MessagesGateway.RedisManager
  alias MessagesGatewayInit

  @messages_gateway_conf "system_config"
  @operators_config "operators_config"
  @first_priority 1
  @type priority_type() :: %{
                             id: String.t(),
                             protocol_name: String.t(),
                             priority: integer(),
                             operator_priority: integer(),
                             configs: map(),
                             limit: integer(),
                             active_protocol_type: boolean(),
                             active: boolean()}

  @type priority_list() :: [priority_type()]


  @spec get_message_priority_list() :: result when
          result: {:ok, {:error, any()} | priority_list()}

  def get_message_priority_list() do
    with messages_gateway_conf <- RedisManager.get(@messages_gateway_conf),
         operators_type_config <- RedisManager.get(@operators_config)
      do
      priority_list = Enum.filter(operators_type_config, fn x -> x.protocol_name != "smtp_protocol" end)
      {:ok, priority_list}
    end
  end

  @spec get_smtp_priority_list() :: result when
          result: {:ok,  {:error, any()} | priority_list()}

  def get_smtp_priority_list() do
    with messages_gateway_conf <- RedisManager.get(@messages_gateway_conf),
         operators_type_config <- RedisManager.get(@operators_config)
      do
      priority_list = Enum.filter(operators_type_config, fn x -> x.protocol_name == "smtp_protocol" end)
      {:ok, priority_list}
    end
  end

  @spec get_priority_list(protocol_name) :: result when
          protocol_name: String.t(),
          result: {:ok,  [nil] | priority_list()}

  def get_priority_list(protocol_name) do
    with operators_type_config <- RedisManager.get(@operators_config) do
      {:ok, [Enum.find(operators_type_config, fn x -> x.protocol_name == protocol_name end)]}
    end
  end
end
