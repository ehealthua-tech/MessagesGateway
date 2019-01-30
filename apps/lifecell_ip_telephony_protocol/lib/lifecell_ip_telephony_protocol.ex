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
    :io.format("~n~p~n", [__MODULE__])
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.set(Atom.to_string(app_name), @protocol_config)
    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{__MODULE__ => "started"}})
    {:ok, []}
  end

  def send_message(%{phone: phone} = payload) do
    try do
  #    run(phone)
  #    end_sending_messages(:success, payload)
      GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{__MODULE__ => "not supported"}})
      end_sending_messages(:error, payload)
    catch
      _ -> end_sending_messages(:error, payload)
    end
  end

  def run(call) do
    call
    |> answer
    |> hangup
    |> terminate
  end


  defp end_sending_messages(:error, payload) do
    RedisManager.set(payload.message_id, :error)
  end

  defp end_sending_messages(:success, payload) do
    message_status_info = RedisManager.get(payload.message_id)
    new_message_status_info = Map.put(message_status_info, :sending_status, true)
    RedisManager.set(payload.message_id, new_message_status_info)
  end
end
