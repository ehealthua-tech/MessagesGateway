defmodule ViberApi do

  alias ViberEndpoint

  def send_message(phone, message) do
      message
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.into(%{})
      :ok

  end

  def add_contact(conn) do
    :io.format("~n~nconn :~p~n", [conn])
    :io.format("~n~nconn :~p~n", [conn.body_params])
    :noreply
  end


  def set_webhook(url)do
    body = %{url: url, event_types: ["delivered", "seen","failed", "subscribed","unsubscribed", "conversation_started"],
                                                                                                send_name: true, send_photo: true}
    ViberEndpoint.request("set_webhook", body)
  end


end
