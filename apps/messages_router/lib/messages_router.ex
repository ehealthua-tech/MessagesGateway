defmodule MessagesRouter do
  @moduledoc false
  alias MessagesRouter.MqManager
  alias MessagesRouter.RedisManager

  @spec send_message(map()) :: :ok | {:error, binary()}
  def send_message(queue_info) do
    RedisManager.get(queue_info.message_id)
    |> check_message_status()
  end

  @spec check_message_status(map() | {:error, binary()}) :: :ok
  defp check_message_status(%{active: true, sending_status: false} = message_status_info), do: select_protocol_and_send(message_status_info)
  defp check_message_status(message_status_info), do: end_sending_message(message_status_info)

  @spec select_protocol_and_send(map()) :: term()
  defp select_protocol_and_send(%{priority_list: priority_list} = message_status_info) when priority_list != [] do
    select_protocol = Enum.min_by(priority_list, fn x -> x.priority end)
    new_priority_list = List.delete(priority_list, select_protocol)
    new_message_status_info = Map.put(message_status_info, :priority_list, new_priority_list)
    check_next_protocol(select_protocol, new_message_status_info)
  end

  @spec check_next_protocol(map(), map()) :: :ok | {:error, binary()} | term()
  defp check_next_protocol(%{active_protocol_type: true, active: true}, message_status_info)  do
    sending_message_to_protocol(message_status_info)
  end
  defp check_next_protocol(_, message_status_info), do: end_sending_message(message_status_info)

  @spec sending_message_to_protocol(map()) :: term()
  def sending_message_to_protocol(message_status_info) do
     protocol_config = RedisManager.get(message_status_info.protocol_name)
     apply(String.to_atom(protocol_config.module_name), String.to_atom(protocol_config.method_name), [message_status_info])
     |> send_message()
  end

  @spec end_sending_message(map()| {:error, binary()}) :: :ok | {:error, binary()}
  defp end_sending_message(message_status_info) do
    new_message_status_info = Map.put(message_status_info, :active, false)
    send_status(message_status_info.callback_url, message_status_info.message_id, new_message_status_info.sending_status)
    MessagesRouter.RedisManager.set(message_status_info.message_id, new_message_status_info)
  end

  @spec send_status(String.t(), String.t(), String.t()) :: :ok | {:ok, HTTPoison.Response.t | HTTPoison.AsyncResponse.t} |
                                                                 {:error, HTTPoison.Error.t}
  defp send_status("",_,_), do: :ok
  defp send_status(callback_url, message_id, sending_status) do
    body = Jason.encode!(%{message_id: message_id, sending_status: sending_status})
    HTTPoison.post(callback_url, body)
  end

end
