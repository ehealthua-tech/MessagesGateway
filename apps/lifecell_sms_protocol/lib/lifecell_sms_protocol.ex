defmodule LifecellSmsProtocol do
  @moduledoc """
  Documentation for LifecellSmsProtocol.
  """
  import SweetXml
  alias LifecellSmsProtocol.EndpointManager
  alias LifecellSmsProtocol.RedisManager
  alias LifecellSmsProtocol.CronManager
  alias LifecellSmsProtocol.MqManager

  @messages_unknown_status ['Accepted', 'Enroute', 'Unknown']
  @messages_error_status   ['Expired', 'Deleted', 'Undeliverable', 'Rejected']
  @messages_success_status ['Delivered']
  @messages_gateway_conf "messages_gateway_conf"
  @send_sms_response_parse_schema [status: ~x"//state/text()", lifecell_sms_id: ~x"./@id", date:  ~x"./@date",
    id: ~x"./@ext_id", error: ~x"//status/state/@error" ]

  @protocol_config %{login: "", password: ""}

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.set(Atom.to_string(app_name), @protocol_config)
    {:ok, []}
  end

  def check_and_send(%{contact: phone, message: message} = payload) do
    :io.format("~nbody~p~n", [phone])
    with {:ok, request_body} <- prepare_request_body(payload),
         {:ok, response_body} <- EndpointManager.prepare_and_send_sms_request(request_body),
         {:ok, pars_body} <- xmap(response_body, @send_sms_response_parse_schema)
      do
        check_sending_status(pars_body, payload)
      else
        error -> end_sending_messages(error)
    end
  end

  def check_message_status(payload) do
    lifacell_sms_info = payload.lifecell_sms_info
    with {:ok, request_body} <- check_status_body(lifacell_sms_info.lifecell_sms_id),
         {:ok, response_body} <- EndpointManager.prepare_and_send_sms_request(request_body),
         {:ok, pars_body} <- xmap(response_body, @send_sms_response_parse_schema)
    do
      check_sending_status(pars_body, payload)
    else
      error -> end_sending_messages(payload)
    end
  end

  def check_sending_status(%{status: status} = pars_body, payload)
      when status in @messages_unknown_status do
    put_in(payload, :lifecell_sms_info, pars_body)
    |> CronManager.schedule_work()
  end

  def check_sending_status(%{status: status} = pars_body, payload)
      when status in @messages_error_status do
    end_sending_messages(payload)
  end

  def check_sending_status(%{status: status} = pars_body, payload)
      when status in @messages_success_status do
    end_sending_messages(payload)
  end

  defp prepare_request_body(payload) do
    with {:ok, sys_config} = RedisManager.get(@messages_gateway_conf)
      do
      send_sms_body(%{phone: payload.phone, message: payload.message,
        sending_time: payload.sending_time, from: sys_config.org_name, message_id: payload.id})
    end
  end

  defp send_sms_body(sending_info)do
    "<message>
       <serviceid=\"single\" validity=\""<>sending_info.sending_time<>"\" source=\""<>sending_info.org_name<>"\"/>
       <to ext_id=\""<>sending_info.message_id<>"\">"<>sending_info.phone<>"</to>
       <body content-type=\"text/plain\""<>sending_info.message<>"</body>
     <message>"
  end

  defp check_status_body(lifecell_sms_id)do
    "<request id="<>lifecell_sms_id<>">status</request>"
  end

  defp end_sending_messages(%{"priority_list" => priority_list} = payload) do
    if priority_list != [] do
      selected_operator = Enum.min_by(priority_list, fn e -> Map.get(e, "priority") end)
      %{"operator_type_id" => operator_type_id} = selected_operator
      new_priority_list = List.delete(priority_list, selected_operator)
      MqManager.send_to_operator(Jason.encode!(Map.put(payload, :priority_list, new_priority_list)), operator_type_id)
    else
      :callback_failed
    end
  end

end

