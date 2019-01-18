defmodule VodafonSmsProtocol do
  @moduledoc """
  Documentation for VodafonSmsProtocol.
  """

  use GenServer
  alias VodafonSmsProtocol.RedisManager

  @protocol_config %{host: "", port: "",  phone_for_send: "", time_for_send: "", system_id: "", password: ""}

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, []}
  end

  def send_message(payload) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    protocol_config = RedisManager.get(Atom.to_string(app_name))
    {:ok, esme} = SMPPEX.ESME.Sync.start_link(protocol_config.host, protocol_config.port)
    bind = SMPPEX.Pdu.Factory.bind_transmitter(protocol_config.system_id, protocol_config.password)
    {:ok, _bind_resp} = SMPPEX.ESME.Sync.request(esme, bind)
    submit_sm = SMPPEX.Pdu.Factory.submit_sm({protocol_config.from, 1, 1}, {payload.phone, 1, 1}, payload)
    {:ok, submit_sm_resp} = SMPPEX.ESME.Sync.request(esme, submit_sm)

    message_id = SMPPEX.Pdu.field(submit_sm_resp, :message_id)

    delivery_report? = fn(pdu) ->
      SMPPEX.Pdu.command_name(pdu) == :deliver_sm and
      SMPPEX.Pdu.field(pdu, :receipted_message_id) == message_id
    end

    delivery_reports = case SMPPEX.ESME.Sync.wait_for_pdus(esme, 60000) do
      :stop ->
        Logger.info("Ooops, ESME stopped")
        []
      :timeout ->
        Logger.info("No DLR in 60 seconds")
        []
      received_items ->
        # Let's filter out DLRs for the previously submitted message
        for {:pdu, pdu}  <- received_items, delivery_report?.(pdu), do: pdu
    end
  end

end
