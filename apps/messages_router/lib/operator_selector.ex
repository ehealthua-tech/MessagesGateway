defmodule OperatorSelector do
  @moduledoc false
  alias MessagesGateway.RedisManager
  alias MessagesRouter.MqManager

  def send_message(payload) do
    message_status_info = RedisManager.get(payload.message_id)
    case check_message_status(message_status_info) do
      :active -> select_protocol_and_send(message_status_info, payload)
      _->  end_sending_message(payload, message_status_info)
    end
  end

  defp check_message_status(%{active: true, sending_status: false}), do: :active
  defp check_message_status(_), do: :no_active

  defp select_protocol_and_send(message_status_info,
         %{"priority_list" => priority_list} = payload) when priority_list != [] do
    select_protocol = Enum.min_by(priority_list, fn x -> x.priority end)
    new_priority_list = List.delete(priority_list, select_protocol)
    new_payload = Map.put(payload, :priority_list, new_priority_list)
    check_next_protocol(select_protocol, message_status_info, new_payload)
  end
  defp select_next_protocol(message_status_info, payload), do: end_sending_message(payload, message_status_info)

  defp check_next_protocol(%{active_protocol_type: true, active: true} = selected_protocol, message_status_info, payload)  do
    sending_message_to_protocol(payload, selected_protocol.protocol_name)
  end
  defp check_next_protocol(selected_protocol, message_status_info, payload) do
    select_next_protocol(message_status_info, payload)
  end

  defp sending_message_to_protocol(payload, protocol_name), do: MqManager.send_to_operator(payload, protocol_name)

  defp end_sending_message(payload, message_status_info) do
    new_message_status_info = Map.put(message_status_info, :active, false)
    RedisManager.set(payload.message_id, new_message_status_info)
    send_status(payload.callback_url, payload.message_id, new_message_status_info.sending_status)
  end

  defp send_status("",_,_), do: :ok
  defp send_status(callback_url, message_id, sending_status) do
    body = Jason.encode!(%{message_id: message_id, sending_status: sending_status})
    HTTPoison.post(callback_url, body)
  end
  
  defp send_status(_,_,_), do: :ok

end
