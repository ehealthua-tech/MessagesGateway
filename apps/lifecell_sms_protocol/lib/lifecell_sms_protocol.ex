defmodule LifecellSmsProtocol do
  @moduledoc """
  Documentation for LifecellSmsProtocol.
  """
  import SweetXml

  def send_message(%{phone: phone, message: message} = payload) do
    "<message>
       <serviceid=\"single\" validity=\"периодактуальности\" source=\"исходящийномер\"/>
       <to ext_id=«опциональный ид. сообщения»>"<>phone<>"</to>
       <body content-type=\"text/plain\""<>message<>"</body>
     <message>"
  end

  def check_status(%{phone: phone, message: message} = payload) do
    "<request id="<>""<>">status</request>"
  end

  def parse_xml(xml, fun) do

    xml = "
    <status id=\"3806712345671174984921384\" date=\"Wed, 28 Mar 2007 12:35:00 +0300\">
    <state>Accepted</state>
    </status>"
    xml
    |> xpath(
    ~x"//status"l,
         status: ~x"//state/text()",
         id: ~x"./@id",
         date:  ~x"./@date"
       )
  end

end

