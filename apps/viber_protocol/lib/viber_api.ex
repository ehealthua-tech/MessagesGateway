defmodule ViberApi do

  alias ViberEndpoint

  def send_message(phone, message) do
    conn = DbAgent.ContactsRequests.select_viber_id(phone)
    :io.format("~n~nconn :~p~n", [conn])
    :io.format("~n~nviber_id :~p~n", [conn.viber_id])
    body = %{receiver: conn.viber_id, min_api_version: 1, sender: %{name: "E-Test", avatar: "http://avatar.example.com"},
      type: "text", text: message}
    {:ok, _} = ViberEndpoint.request("send_message", body)
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
         tracking_data: "Phone_number", type: "text", text: "Щоб отримувати отримувати повідомлення, будь ласка,
          увімкніть діалог(в меню інформація) та введіть Ваший номер телефону у форматі +380ххххххххх"}
    {:ok, _} = ViberEndpoint.request("send_message", body)

  end

  def check_body("text", body) do
    :io.format("~n~ntext :~p~n", [body])

    message = get_in(body, ["message"])
    tracking_data = get_in(message, ["tracking_data"])
    text = get_in(message, ["text"])

    sender  = get_in(body, ["sender"])
    user_id = get_in(sender, ["id"])

    check_phone_number(tracking_data, text, user_id)
  end

  def check_phone_number("Phone_number", text, user_id) do
    length = String.length(text)
    case length do
      13 ->
        [_, number] = String.split(text, "+380")
        case is_integer(number) do
          true -> DbAgent.ContactsRequests.add_viber_id(%{phone_number: text, viber_id: user_id})
                  :noreply
          _-> :noreply
        end
        _->  :noreply
    end
  end

end
