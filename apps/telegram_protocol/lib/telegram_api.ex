defmodule TelegramApi do

    def send_message(phone, message) do
      # TELEGRAM.API
      #    priority_list = Map.get(payload, :priority_list)
      #    if priority_list != [] do
      #      selected_operator = Enum.min_by(priority_list, fn e -> Map.get(e, "priority") end)
      #      %{"operator_type_id" => operator_type_id} = selected_operator
      #      new_priority_list = List.delete(priority_list, selected_operator)
      #      send_to_operator(Map.put(payload, :priority_list, new_priority_list), operator_type_id)
      #    else
      #      :no_operators_remaining
      #    end
      :io.format("~nTELEGRAM~n")
      :ok
    end

  end
