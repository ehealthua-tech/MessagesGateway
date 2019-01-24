defmodule LifecellIpTelephonyProtocol do
  @moduledoc """
  Documentation for LifecellIpTelephonyProtocol.
  """
  @protocol_config %{host: "", port: ""}
  use SpeakEx.CallController
  alias LifecellIpTelephonyProtocol.MqManager
  alias LifecellIpTelephonyProtocol.RedisManager

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.set(Atom.to_string(app_name), @protocol_config)
    url = Application.get_env(:lifecell_ip_telephony_protocol, :elasticsearch_url)
    HTTPoison.post(Enum.join([url, "/log_lifecell_ip_telephony_protocol/log"]), Jason.encode!(%{status: "protocol started"}), [{"Content-Type", "application/json"}])
    {:ok, []}
  end

  def send_message(%{phone: phone} = payload) do
    try do
      run(phone)
      end_sending_messages(:success, payload)
    catch
      _ -> end_sending_messages(:error, payload)
    end
  end

  def run(call) do
    call
    |> answer!
    |> hangup!
    |> terminate!
  end

  defp end_sending_messages(:error, payload) do
    MqManager.send_to_operator(Jason.encode!(payload), "message_queue")
  end

  defp end_sending_messages(:success, payload) do
    message_status_info = RedisManager.get(payload.message_id)
    new_message_status_info = Map.put(message_status_info, :sending_status, true)
    RedisManager.set(payload.message_id, new_message_status_info)
    MqManager.send_to_operator(Jason.encode!(payload), "message_queue")
  end
end
