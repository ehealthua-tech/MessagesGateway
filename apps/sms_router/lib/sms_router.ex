defmodule SmsRouter do
  @moduledoc """
  Documentation for SmsRouter.
  """
  alias SmsRouter.RedisManager
  alias DbAgent.ContactsRequests

  @operator_codes :operator_codes
  @operation_info "operators_info"

  def check_and_send(message) do
    operator_id = search_contact_in_db(message)
    MqSubscriber.send_to_operator(message, operator_id)
  end

  defp search_contact_in_db(message) do
    ContactsRequests.get_by_phone_number!(message.phone)
    |> check_operator_id(message)
  end

  defp check_operator_id(contact_info, message) when contact_info == nil, do: calc_operator_info(message)
  defp check_operator_id(contact_info, message) do
    case contact_info.operator_id do
      nil -> calc_operator_info(message)
      res -> res
    end
  end

  defp calc_operator_info(message, viber_id \\ nil ) do
    phone_code = binary_part(message.phone, 0, 6)
    operator =
      RedisManager.get(@operation_info)
      |> select_operators(phone_code)
    ContactsRequests.add_operator_id(%{phone_number: message.phone, operator_id: operator.id, viber_id: viber_id})
    operator.id
  end

  defp select_operators([], __), do: :default
  defp select_operators([operator_info | other_operators], phone_code) do
    case Map.has_key?(operator_info, @operator_codes) do
      true ->  check_phone_belong_operator(operator_info, phone_code, other_operators)
      _-> select_operators(other_operators, phone_code)
     end
  end

  defp check_phone_belong_operator(operator_info, phone_code, other_operators) do
    case Enum.member?(operator_info.operator_codes, phone_code) do
       true -> operator_info
       _-> select_operators(other_operators, phone_code)
    end
  end

end
