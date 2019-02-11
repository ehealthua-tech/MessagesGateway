defmodule MessagesRouter do
  @moduledoc false
  alias MessagesRouter.RedisManager

  @messages_gateway_conf "system_config"
  @operators_config "operators_config"
  @sms_protocol "sms_protocol"

# ---  sending`s statuses  --
  @error_send_status "sending_error"
  @read_status "read"
  @delivered_status "delivered"
  @in_queue_status "in_queue"
  @in_process_status "sending"

# ---  groups of sending`s statuses  --
  @end_status [ @read_status, @delivered_status, @error_send_status]
  @pending_status [@in_queue_status, @in_process_status]

  @spec send_message(map()) :: :ok | {:error, binary()}
  def send_message(queue_info) do
    RedisManager.get(queue_info.message_id)
    |> check_message_status()
  end

  @spec check_message_status(map() | {:error, binary()}) :: :ok
  defp check_message_status(%{active: true, sending_status: sending_status} = message_info)
       when sending_status in @pending_status do
    new_message_info = Map.put(message_info, :sending_status, @in_process_status)
    RedisManager.set(message_info.message_id, new_message_info)
    system_config =  RedisManager.get(@messages_gateway_conf)
    select_protocol_and_send(new_message_info, system_config)
  end
  defp check_message_status(message_status_info), do: end_sending_message(message_status_info)

  @spec select_protocol_and_send(map(), map()) :: term()
  defp select_protocol_and_send(%{priority_list: priority_list} = message_status_info, system_config) when priority_list != [] do
    selected_protocol = select_priority(system_config, priority_list)
    new_priority_list = List.delete(priority_list, selected_protocol)
    new_message_status_info = Map.put(message_status_info, :priority_list, new_priority_list)
    RedisManager.set(new_message_status_info.message_id, new_message_status_info)
    check_next_protocol(selected_protocol, new_message_status_info, system_config)
  end

  defp select_protocol_and_send(%{subject: _sub} = message_info, _) do
    new_message_info = Map.put(message_info, :sending_status, @error_send_status)
    RedisManager.set(message_info.message_id, new_message_info)
    end_sending_message(new_message_info)
  end

  defp select_protocol_and_send(message_info, %{automatic_prioritization: true}) do
    protocol_from_db =
      RedisManager.get(@operators_config)
      |> Enum.filter( fn x -> x.protocol_name =~ @sms_protocol end)
      |> Enum.min_by(fn x -> x.configs.sms_price_for_external_operator end)
    protocol_config = RedisManager.get(protocol_from_db.protocol_name)
    case protocol_from_db do
      %{active_protocol_type: true, active: true} ->
        new_message_info = Map.put(message_info, :sending_status, @error_send_status)
        RedisManager.set(message_info.message_id, new_message_info)
        apply(String.to_atom(protocol_config.module_name), String.to_atom(protocol_config.method_name), [new_message_info])
      _-> end_sending_message(message_info)
    end
  end

  defp select_priority(%{automatic_prioritization: false}, priority_list) do
    Enum.min_by(priority_list, fn x -> x.priority end)
  end

  defp select_priority(%{automatic_prioritization: true}, priority_list) do
    Enum.min_by(priority_list, fn x -> x.operator_priority end)
  end

  @spec check_next_protocol(map(), map(), map()) :: :ok | {:error, binary()} | term()
  defp check_next_protocol(%{active_protocol_type: true, active: true} = protocol, message_status_info, system_config) do
    sending_message_to_protocol(protocol.protocol_name =~ @sms_protocol, protocol, message_status_info, system_config)
  end
  defp check_next_protocol(_, message_status_info, _) do
    check_message_status(message_status_info)
  end


  @spec sending_message_to_protocol(atom(), map(), map(), map()) :: term()
  def sending_message_to_protocol(true, protocol, %{contact: <<contact::binary-size(6)>><>_some}= message_info,
        %{automatic_prioritization: true}) do
    protocol_config = RedisManager.get(protocol.protocol_name)
    case Enum.member?(String.split(protocol_config.code), contact) do
      true ->
        apply(String.to_atom(protocol_config.module_name), String.to_atom(protocol_config.method_name), [message_info])
      _-> check_message_status(message_info)
    end
  end

  def sending_message_to_protocol(true, _, message_status_info, %{automatic_prioritization: false} = system_config) do
    apply(String.to_atom(system_config.sms_router_module),  String.to_atom(system_config.sms_router_method),
      [message_status_info])
  end

  def sending_message_to_protocol(_, protocol, message_status_info, _) do
    protocol_config = RedisManager.get(protocol.protocol_name)
    apply(String.to_atom(protocol_config.module_name), String.to_atom(protocol_config.method_name),
      [message_status_info])
  end

  @spec end_sending_message(map()| {:error, binary()}) :: :ok | {:error, binary()}
  defp end_sending_message({:error, :not_found}), do: :ok
  defp end_sending_message(message_status_info) do
    new_message_status_info = Map.merge(message_status_info, %{active: false})
    send_status(message_status_info.callback_url, message_status_info.message_id,
      new_message_status_info.sending_status)
    RedisManager.set(message_status_info.message_id, new_message_status_info)
  end

  @spec send_status(String.t(), String.t(), String.t()) :: :ok | {:ok, HTTPoison.Response.t |
                                                                       HTTPoison.AsyncResponse.t} |
                                                                 {:error, HTTPoison.Error.t}
  defp send_status("",_,_), do: :ok
  defp send_status(callback_url, message_id, sending_status) do
    body = Jason.encode!(%{message_id: message_id, sending_status: sending_status})
    HTTPoison.post(callback_url, body)
  end

end
