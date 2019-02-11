defmodule SmsRouter do
  @moduledoc """
  Documentation for SmsRouter.
  """
  alias SmsRouter.RedisManager
  alias DbAgent.ContactsRequests

  @operator_codes :code
  @messages_gateway_conf "system_config"
  @operators_config "operators_config"

  def check_and_send(message) do
    ContactsRequests.get_by_phone_number!(message.contact)
    |> check_operator_id(message)
  end

  defp search_contact_in_db(message) do
    ContactsRequests.get_by_phone_number!(message.contact)
    |> check_operator_id(message)
  end

  defp check_operator_id(contact_info, message_info) when contact_info == nil, do: calc_operator_info(message_info)
  defp check_operator_id(contact_info, message_info), do: calc_operator_info(message_info, contact_info.viber_id)

  defp calc_operator_info(message_info, viber_id \\ nil ) do
    phone_code = binary_part(message_info.contact, 0, 6)
    operator =
      RedisManager.get(@operators_config)
      |> select_operators(phone_code)
      |> select_protocol_for_send(message_info, viber_id)
  end

  defp select_operators({:error, _}, __), do: :default
  defp select_operators([], __), do: :default
  defp select_operators([%{configs: configs} = operator_info | other_operators], phone_code) do
    case Map.has_key?(configs, @operator_codes) do
      true ->  check_phone_belong_operator(operator_info, phone_code, other_operators)
      _-> select_operators(other_operators, phone_code)
     end
  end

  defp check_phone_belong_operator(%{configs: configs} = operator_info, phone_code, other_operators) do
    case Enum.member?(String.split(configs.code), phone_code) do
       true -> operator_info
       _-> select_operators(other_operators, phone_code)
    end
  end

  defp select_protocol_for_send(:default, message_info, viber_id) do
    mg_config = RedisManager.get(@messages_gateway_conf)
    :io.format("~nmg_config: ~p~n", [mg_config])
    x = RedisManager.get(Map.get(mg_config, :default_sms_operator, "nil"))
    :io.format("~nx : ~p~n", [x ])
     send_to_protocol(x, message_info)
  end
  defp select_protocol_for_send(protocol_config, message_info, viber_id) do
    ContactsRequests.add_operator_id(%{phone_number: message_info.contact, operator_id: protocol_config.id, viber_id: viber_id})
    RedisManager.get(protocol_config.protocol_name)
    |> send_to_protocol(message_info)
  end

  defp send_to_protocol({:error, _}, message_info)  do
    system_config =  RedisManager.get(@messages_gateway_conf)
    apply(String.to_atom(system_config.messages_router_module), String.to_atom(system_config.messages_router_method), [message_info])
  end

  defp send_to_protocol(protocol_config, message_info) do
    apply(String.to_atom(protocol_config.module_name), String.to_atom(protocol_config.method_name), [message_info])
  end

end
