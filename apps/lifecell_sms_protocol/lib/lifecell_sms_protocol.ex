defmodule LifecellSmsProtocol do
  @moduledoc """
  Documentation for LifecellSmsProtocol.
  """
  import SweetXml
  alias LifecellSms.EndpointManager
  alias LifecellSms.RedisManager
  @messages_unknown_status ['Accepted', 'Enroute', 'Unknown']
  @messages_error_status   ['Expired', 'Deleted', 'Undeliverable', 'Rejected']
  @messages_success_status ['Delivered']
  @messages_gateway_conf "messages_gateway_conf"
  @send_sms_response_parse_schema [status: ~x"//state/text()", lifecell_sms_id: ~x"./@id", date:  ~x"./@date", id: ~x"./@ext_id", error: ~x"//status/state/@error" ]

  def send_message(%{phone: phone, message: message} = payload) do

    with {:ok, request_body} <- prepare_request_body(payload),
         {:ok, response_body} <- EndpointManager.prepare_and_send_sms_request(request_body),
         {:ok, pars_body} <- xmap(response_body, @send_sms_response_parse_schema)
      do
        check_sending_status(pars_body, payload)
      else
        error -> end_sending_messages(error)
    end

  end

  def cgeck_message_status(lifecell_message_id)

  def check_sending_status(%{status: status} = pars_body, payload)
      when status in @messages_unknown_status do
    send_sms_body(payload.lifecell_sms_id)
  end

  def check_sending_status(%{status: status} = pars_body, payload)
      when status in @messages_error_status do
    send_sms_body(payload.lifecell_sms_id)
  end

  def check_sending_status(%{status: status} = pars_body, payload)
      when status in @messages_success_status do
    send_sms_body(payload.lifecell_sms_id)
  end

  defp end_sending_messages(payload)do
    payload
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

  defp check_status_body(message_id)do
    "<request id="<>message_id<>">status</request>"
  end

end

