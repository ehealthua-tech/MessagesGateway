defmodule VodafonSmsProtocol do
  @moduledoc """
  Documentation for VodafonSmsProtocol.
  """

  use GenServer
  alias VodafonSmsProtocol.RedisManager
  alias VodafonSmsProtocol.MqManager

  @protocol_config %{host: "", port: "",  phone_for_send: "", time_for_send: "", system_id: "", password: ""}

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    url = Application.get_env(:vodafon_sms_protocol, :elasticsearch_url)
    HTTPoison.post(Enum.join([url, "/log_vodafon_sms_protocol/log"]), Jason.encode!(%{status: "protocol started"}), [{"Content-Type", "application/json"}])
    {:ok, []}
  end

  def send_message(payload) do
    url = Application.get_env(:vodafon_sms_protocol, :elasticsearch_url)
    HTTPoison.post(Enum.join([url, "/log_vodafon_sms_protocol/log"]), Jason.encode!(%{status: "not supported"}), [{"Content-Type", "application/json"}])
    MqManager.send_to_operator(Jason.encode!(payload), "message_queue")
#    with {:ok, app_name} <- :application.get_application(__MODULE__),
#        protocol_config <- RedisManager.get(Atom.to_string(app_name)),
#        {:ok, esme} <- SMPPEX.ESME.Sync.start_link(protocol_config.host, protocol_config.port),
#        bind <- SMPPEX.Pdu.Factory.bind_transmitter(protocol_config.system_id, protocol_config.password),
#        {:ok, bind_resp} <- SMPPEX.ESME.Sync.request(esme, bind),
#        submit_sm <- SMPPEX.Pdu.Factory.submit_sm({protocol_config.from, 1, 1}, {payload.contact, 1, 1}, payload.body),
#        {:ok, submit_sm_resp} <- SMPPEX.ESME.Sync.request(esme, submit_sm),
#        message_id <- SMPPEX.Pdu.field(submit_sm_resp, :message_id),
#        delivery_report <- wait_delivery_report(message_id),
#        status <- SMPPEX.ESME.Sync.wait_for_pdus(esme, payload.time_for_send)
#      do
#        end_sending_messages(status, delivery_report, esme, bind_resp, payload)
#    end
  end

  defp  wait_delivery_report(message_id) do
    fn(pdu) ->
      SMPPEX.Pdu.command_name(pdu) == :deliver_sm and
      SMPPEX.Pdu.field(pdu, :receipted_message_id) == message_id
    end
  end

  defp end_sending_messages(:stop, delivery_report, esme, bind_resp, payload) do
    MqManager.send_to_operator(Jason.encode!(payload), "message_queue")
  end

  defp end_sending_messages(:timeout, delivery_report, esme, bind_resp, payload) do
     MqManager.send_to_operator(Jason.encode!(payload), "message_queue")
  end

  defp end_sending_messages(received_items, delivery_report, esme, bind_resp, payload) do
    pdu =for {:pdu, pdu}  <- received_items, delivery_report.(pdu), do: pdu
    case pdu == bind_resp do
      true->
        message_status_info = RedisManager.get(payload.message_id)
        new_message_status_info = Map.put(message_status_info, :sending_status, true)
        RedisManager.set(payload.message_id, new_message_status_info)
        MqManager.send_to_operator(Jason.encode!(payload), "message_queue")
      _-> MqManager.send_to_operator(Jason.encode!(payload), "message_queue")
    end
  end

end
