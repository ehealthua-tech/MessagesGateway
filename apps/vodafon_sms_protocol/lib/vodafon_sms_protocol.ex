defmodule VodafonSmsProtocol do
  @moduledoc """
  Documentation for VodafonSmsProtocol.
  """

  use GenServer
  alias VodafonSmsProtocol.RedisManager

  @protocol_config %{host: "", port: "",  phone_for_send: "", time_for_send: "", system_id: "", password: "",
    module_name: __MODULE__, method_name: :send_message}

  @protocol_config_def %{login: "", password: "", code: "", module_name: __MODULE__, method_name: :send_message }

  #--- Init and start protocol------------------------------------------------------

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.get(Atom.to_string(app_name))
    |> check_config(app_name)

    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{__MODULE__ => "started"}})
    {:ok, []}
  end

  defp check_config({:error, _}, app_name), do: RedisManager.set(Atom.to_string(app_name), @protocol_config_def)
  defp check_config(protocol_config, app_name) do
    case Map.keys(protocol_config) ==  Map.keys(@protocol_config_def) do
      true -> :ok
      _->
        config = for {k, v} <- @protocol_config_def, into: %{}, do: {k, Map.get(protocol_config, k, v)}
        RedisManager.set(Atom.to_string(app_name), config)
    end
  end


  def send_message(message_info) do
    end_sending_messages(message_info)
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

  defp end_sending_messages(message_info) do
    :io.format("Vodafon SMS error sending message")
    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{__MODULE__ => "not supported"}})
    apply(:'Elixir.MessagesRouter', :send_message, [%{message_id: message_info.message_id}])
  end

end
