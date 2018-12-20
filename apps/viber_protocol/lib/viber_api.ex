defmodule ViberApi do

  alias ViberEndpoint

  def send_message(phone, message) do
      message
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.into(%{})
      :ok

  end

  def send_message(phone, message) do
    message
    |> Enum.filter(fn {_, v} -> v end)
    |> Enum.into(%{})
    :noreply
  end


  def set_webhook(url)do
    body = %{url: url, event_types: ["delivered", "seen","failed", "subscribed","unsubscribed", "conversation_started"],
                                                                                                send_name: true, send_photo: true}
    ViberEndpoint.request("set_webhook", body)
  end


end
