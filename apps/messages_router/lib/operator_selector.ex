defmodule OperatorSelector do
  @moduledoc false

  def send_message(%{"message_id" => message_id, "priority_list" => priority_list} = payload) do
    message_info = MessagesGateway.RedisManager.get(message_id)
    %{"active" => active, "sending_status" => sending_status} = Jason.decode!(message_info)
    if active do
      if sending_status == false do
        if priority_list != [] do
          selected_operator = Enum.min_by(priority_list, fn e -> Map.get(e, "priority") end)
          %{"operator_type_id" => operator_type_id} = selected_operator
          new_priority_list = List.delete(priority_list, selected_operator)
          MessagesRouter.MqManager.send_to_operator(Jason.encode!(Map.put(payload, :priority_list, new_priority_list)), operator_type_id)
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

end
