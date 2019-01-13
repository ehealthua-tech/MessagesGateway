defmodule LifecellIpTelephonyProtocol do
  @moduledoc """
  Documentation for LifecellIpTelephonyProtocol.
  """

  use SpeakEx.CallController

  def send_message(%{phone: phone} = payload) do
    try do
      run(phone)
      change_status(payload)
    catch
      _ -> resend(payload)
    end
  end

  def run(call) do
    call
    |> answer!
    |> hangup!
    |> terminate!
  end

  defp resend(payload) do
    if payload.priority_list != [] do
      selected_operator = Enum.min_by(payload.priority_list, fn e -> e.priority end)
      operator_type_id = selected_operator.operator_type_id
      new_priority_list = List.delete(payload.priority_list, operator_type_id)
      LifecellIpTelephony.MqManager.send_to_operator(Jason.encode!(Map.put(payload, :priority_list, new_priority_list)), operator_type_id)
    else
      :callback_failed
    end

  end
end
