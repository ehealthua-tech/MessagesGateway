defmodule ViberApi do

  alias ViberEndpoint

  def send_message(phone, message) do
      DbAgent.select_viber_id(phone)

  end

  def add_contact(conn) do
    :io.format("~n~nconn :~p~n", [conn])
    :io.format("~n~nconn :~p~n", [conn.body_params])
    body = conn.body_params
    Map.get(body, "event")
    |> check_body(body)

  end


  def set_webhook(url)do
    body = %{url: url, event_types: ["delivered", "seen","failed", "subscribed","unsubscribed", "conversation_started"],
                                                                                                send_name: true, send_photo: true}
    ViberEndpoint.request("set_webhook", body)
  end

  def check_body("webhook", body) do
    :noreply
  end

  def check_body("subscribed", body) do
    id = get_in(body, ["user", "id"])
      with {:ok, result} = ViberEndpoint.request("get_user_details", %{id: id}) do
    end
  end

  def check_body("conversation_started", body) do
    id = get_in(body, ["user", "id"])
    body = %{receiver: id, min_api_version: 1, sender: %{name: "E-Test", avatar: "http://avatar.example.com"},
         tracking_data: "Phone_number", type: "text", text: "Введіть Ваший номер телефону у форматі +380ххххххххх"}
    {:ok, result} = ViberEndpoint.request("send_message", %{id: id})

  end

end
