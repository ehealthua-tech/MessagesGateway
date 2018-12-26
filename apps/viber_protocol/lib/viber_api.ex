defmodule ViberApi do

  alias ViberEndpoint

  def send_message(%{"contact" => phone, "body" => message} = payload) do
    conn = DbAgent.ContactsRequests.select_viber_id(phone)
    :io.format("~n~nconn :~p~n", [conn])
    :io.format("~n~nviber_id :~p~n", [conn.viber_id])
    body = %{receiver: conn.viber_id, min_api_version: 1, sender: %{name: "E-Test", avatar: "http://avatar.example.com"},
      type: "text", text: message}
    :io.format("~nVIBER API~n")
    if {:ok, 2} = ViberEndpoint.request("send_message", body) do
      :ok
    else
      resend(payload)
    end
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
    :io.format("~nBody webhook~n~p~n",[body])
    :noreply
  end

  def check_body("seen", body) do
    :io.format("~nBody seen~n~p~n",[body])
    :noreply
  end

  def check_body("delivered", body) do
    :io.format("~nBody delivired~n~p~n",[body])
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
         tracking_data: "Phone_number", type: "text", text: "Щоб отримувати повідомлення, будь ласка,
          увімкніть діалог(в меню інформація) та введіть Ваший номер телефону у форматі +380ххххххххх"}
    {:ok, _} = ViberEndpoint.request("send_message", body)

  end

  def check_body("message", body) do
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
    case length == 13 do
      true ->
        :io.format("~n~nlength :~p~n", [length])
        [_, number] = String.split(text, "+380")
        :io.format("~n~nlength :~p~n", [length])
        case String.to_integer(number) do
          x ->
            :io.format("~n~nx :~p~n", [x])
            DbAgent.ContactsRequests.add_viber_id(%{phone_number: text, viber_id: user_id})
                  :noreply
          _-> :noreply
        end
        _->  :noreply
    end
  end

  defp resend(%{"priority_list" => priority_list} = payload) do
    if priority_list != [] do
      selected_operator = Enum.min_by(priority_list, fn e -> Map.get(e, "priority") end)
      %{"operator_type_id" => operator_type_id} = selected_operator
      new_priority_list = List.delete(priority_list, selected_operator)
      TelegramSubscriber.send_to_operator(Jason.encode!(Map.put(payload, :priority_list, new_priority_list)), operator_type_id)
    else
      :callback_failed
    end
  end

end
