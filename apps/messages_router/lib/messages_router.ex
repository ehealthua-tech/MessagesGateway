defmodule MessagesRouter do
  @moduledoc false
  alias MessagesRouter.MqManager
  alias MessagesRouter.RedisManager

  @spec send_message(map()) :: :ok | {:error, binary()}
  def send_message(payload) do
    message_status_info = MessagesRouter.RedisManager.get(payload.message_id)
    case check_message_status(message_status_info) do
      :active -> select_protocol_and_send(message_status_info, payload)
      :no_active -> end_sending_message(payload, message_status_info)
    end
  end

  @spec check_message_status(map() | {:error, binary()}) :: :active | :no_active
  defp check_message_status(%{active: true, sending_status: false}), do: :active
  defp check_message_status(_), do: :no_active

  @spec select_protocol_and_send(map(), map()) :: term()
  defp select_protocol_and_send(message_status_info,
         %{priority_list: priority_list} = payload) when priority_list != [] do
    select_protocol = Enum.min_by(priority_list, fn x -> x.priority end)
    new_priority_list = List.delete(priority_list, select_protocol)
    new_payload = Map.put(payload, :priority_list, new_priority_list)
    check_next_protocol(select_protocol, message_status_info, new_payload)
  end

  @spec select_next_protocol(map(), map()) :: :ok | {:error, binary()}
  defp select_next_protocol(message_status_info, payload), do: end_sending_message(payload, message_status_info)

  @spec check_next_protocol(map(), map(), map()) :: :ok | {:error, binary()} | term()
  defp check_next_protocol(%{active_protocol_type: true, active: true} = selected_protocol, _, payload)  do
    sending_message_to_protocol(payload)
  end
  defp check_next_protocol(_, message_status_info, payload) do
    select_next_protocol(message_status_info, payload)
  end

  @spec sending_message_to_protocol(map()) :: term()
  def sending_message_to_protocol(payload) do
     protocol_config = RedisManager.get(payload.protocol_name)
     :io.format("~nx~p~n", [protocol_config])
     x = apply(String.to_atom(protocol_config.module_name), String.to_atom(protocol_config.method_name), [payload])
     :io.format("~nx~p~n", [x])
  end

  @spec end_sending_message(map(), map() | {:error, binary()}) :: :ok | {:error, binary()}
  defp end_sending_message(payload, message_status_info) do
    new_message_status_info = Map.put(message_status_info, :active, false)
    send_status(payload.callback_url, payload.message_id, new_message_status_info.sending_status)
    MessagesRouter.RedisManager.set(payload.message_id, new_message_status_info)
  end

  @spec send_status(String.t(), String.t(), String.t()) :: :ok | {:ok, HTTPoison.Response.t | HTTPoison.AsyncResponse.t} |
                                                                 {:error, HTTPoison.Error.t}
  defp send_status("",_,_), do: :ok
  defp send_status(callback_url, message_id, sending_status) do
    body = Jason.encode!(%{message_id: message_id, sending_status: sending_status})
    HTTPoison.post(callback_url, body)
  end

end
