defmodule OperatorSelector do
  @moduledoc false

  def send_message(%{message_id: message_id, priority_list: priority_list} = payload) do
    :io.format("Operator selector for:~p~n",[payload])
    %{active: active, sending_status: sending_status} = Redis.get(message_id)
    if active do
      if sending_status == false do
        if priority_list != [] do
          [provider | new_priority_list] = priority_list
          send_to_operator(payload, provider)
        else
          :callback_failed
        end
      else
        :callback_ok
      end
    else
      :callback_deactivated
    end
  end

  defp send_to_operator(payload, provider) do
    # MqSubscriber.send_to_operator(payload, operator)
    :io.format("Sent to provider queue")
  end

end
