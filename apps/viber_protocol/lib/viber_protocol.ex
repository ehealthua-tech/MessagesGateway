defmodule ViberProtocol do
  use GenServer
  alias ViberProtocol.RedisManager
  alias ViberEndpoint

  @event_types ["delivered", "seen", "failed", "subscribed","unsubscribed", "conversation_started"]
  @protocol_config %{auth_token: ""}

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.set(Atom.to_string(app_name), @protocol_config)
    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{__MODULE__ => "started"}})
    {:ok, []}
  end

  def send_message(%{"message_id" => message_id, "contact" => phone, "body" => message} = payload) do
    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{:message_id => message_id, status: "sending_viber"}})
    conn = DbAgent.ContactsRequests.get_by_phone_number!(phone)
    :io.format("~nconn: ~p~n", [conn])
    case conn do
      nil -> resend(payload)
      _->
        body = %{receiver: conn.viber_id, min_api_version: 1, sender: %{name: "E-Test"},type: "text", text: message}
        {:ok, answer} = ViberEndpoint.request("send_message", body)
        if "ok" ==  Map.get(answer, :status_message) do
          GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{"message_id" => message_id, "status" => "sent"}})
          :ok
        else
          resend(payload)
        end
    end
  end

  def add_contact(conn) do

    body = conn.body_params
    Map.get(body, "event")
    |> check_body(body)

  end

  def set_webhook(url)do
    body = %{url: url, event_types: @event_types,
      send_name: true, send_photo: true}
    ViberEndpoint.request("set_webhook", body)
  end

  def check_body("webhook", body) do
    :noreply
  end

  def check_body("seen", body) do
    :noreply
  end

  def check_body("delivered", body) do
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
        [_, number] = String.split(text, "+380")
        case String.to_integer(number) do
          x ->
            DbAgent.ContactsRequests.add_viber_id(%{phone_number: text, viber_id: user_id})
            :noreply
          _-> :noreply
        end
      _->  :noreply
    end
  end

  #  defp resend(%{"priority_list" => priority_list} = payload) do
  #    if priority_list != [] do
  #      selected_operator = Enum.min_by(priority_list, fn e -> Map.get(e, "priority") end)
  #      %{"operator_type_id" => operator_type_id} = selected_operator
  #      new_priority_list = List.delete(priority_list, selected_operator)
  #      ViberProtocol.MqManager.send_to_operator(Jason.encode!(Map.put(payload, :priority_list, new_priority_list)), operator_type_id)
  #    else
  #      :callback_failed
  #    end
  #  end

  defp resend(payload) do
    :ok
  end

end