defmodule LifecellSmsProtocol do
  @moduledoc """
  Documentation for LifecellSmsProtocol.
  """
  import SweetXml
  alias LifecellSmsProtocol.EndpointManager
  alias LifecellSmsProtocol.RedisManager

  @messages_unknown_status ['Accepted', 'Enroute', 'Unknown']
  @messages_error_status   ['Expired', 'Deleted', 'Undeliverable', 'Rejected']
  @messages_success_status ['Delivered']
  @messages_gateway_conf "system_config"
  @send_sms_response_parse_schema [status: ~x"//state/text()", lifecell_sms_id: ~x"./@id", date:  ~x"./@date",
    id: ~x"./@ext_id", error: ~x"//status/state/@error" ]
  @endpoint Application.get_env(:viber_protocol, :viber_endpoint)

  @protocol_config_def %{login: "", password: "", code: "", module_name: __MODULE__, method_name: :send_message, sms_price_for_external_operator: 0 }

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

  #--- send message ------------------------------------------------------
  def send_message(%{contact: phone, body: message} = payload) do
    with {:ok, request_body} <- prepare_request_body(payload),
         {:ok, response_body} <- @endpoint.prepare_and_send_sms_request(request_body),
         {:ok, pars_body} <- xmap(response_body, @send_sms_response_parse_schema)
      do
      reference = Process.send_after( __MODULE__, {:end_sending_message, payload.message_id}, 10000)
      GenServer.cast(__MODULE__, {:add_to_state, %{message_id: payload.message_id, reference: reference}})
      check_sending_status(pars_body, payload)
    else
      error ->
        :io.format("~nerror:~n~p~n", [error])
        end_sending_message(:error, payload.message_id)
    end
  end

  def check_message_status(payload) do
    lifacell_sms_info = payload.lifecell_sms_info
    with request_body <- check_status_body(lifacell_sms_info.lifecell_sms_id),
         {:ok, response_body} <- @endpoint.prepare_and_send_sms_request(request_body),
         pars_body <- xmap(response_body, @send_sms_response_parse_schema)
    do
      check_sending_status(pars_body, payload)
    else
      error -> end_sending_message(:error, payload.message_id)
    end
  end

  def check_sending_status(%{status: status} = pars_body, payload)
      when status in @messages_unknown_status do
    Process.send_after(__MODULE__, {:check_message_status, pars_body, payload}, 3000)
  end
  def check_sending_status(%{status: status} = pars_body, payload)
      when status in @messages_error_status do
    end_sending_message(:error, payload.message_id)
  end

  def handle_info({:end_sending_message, message_id}, state) do
    message_info = Enum.find(state, fn x -> Map.get(x, :message_id, :nil) == message_id end)
    new_state = List.delete(state, message_info)
    spawn(__MODULE__, :end_sending_message, [:error, message_info.message_id])
    {:noreply, new_state}
  end

  def handle_cast({:check_message_status, pars_body, message_info}, state) do
    check_sending_status(%{status: status, message_id: message_id} = pars_body, message_info)
    {:noreply, state}
  end

  def check_sending_status(%{status: status, message_id: message_id} = pars_body, payload)
      when status in @messages_success_status do
    message_status_info = RedisManager.get(message_id)
    new_message_status_info = Map.put(message_status_info, :sending_status, true)
    RedisManager.set(payload.message_id, new_message_status_info)
    end_sending_message(:error, payload.message_id)
  end

  def check_sending_status(_, payload), do: end_sending_message(:error, payload.message_id)
  defp prepare_request_body(payload) do
    with sys_config = RedisManager.get(@messages_gateway_conf)
      do
      {:ok, send_sms_body(%{phone: payload.contact, message: payload.body,
        sending_time: sys_config.sending_time, from: sys_config.org_name, message_id: payload.message_id})}
    end
  end

  defp send_sms_body(sending_info)do
    "<message>
       <serviceid=\"single\" validity=\""<>sending_info.sending_time<>"\" source=\""<>sending_info.from<>"\"/>
       <to ext_id=\""<>sending_info.message_id<>"\">"<>sending_info.phone<>"</to>
       <body content-type=\"text/plain\""<>sending_info.message<>"</body>
     <message>"
  end

  defp check_status_body(lifecell_sms_id)do
    "<request id="<>lifecell_sms_id<>">status</request>"
  end

  @spec end_sending_message(any(), :nil | String.t()) :: :ok | any()

  def end_sending_message(_, :nil), do: :ok
  def end_sending_message(:success, message_id) do
    message_status_info =
      RedisManager.get(message_id)
      |> Map.put(:sending_status, "read")
    RedisManager.set(message_id, message_status_info)
    {:ok, app_name} = :application.get_application(__MODULE__)
    protocol =  RedisManager.get(Atom.to_string(app_name))
    apply(String.to_atom(protocol.module_name), String.to_atom(protocol.method_name), [%{message_id: message_id}])
  end

  def end_sending_message(:error, message_id) do
    :io.format("~nmessage_id: ~p~n", [message_id])
    {:ok, app_name} = :application.get_application(__MODULE__)
    protocol =  RedisManager.get(Atom.to_string(app_name))
    apply(String.to_atom(protocol.module_name), String.to_atom(protocol.method_name), [%{message_id: message_id}])
  end

end

