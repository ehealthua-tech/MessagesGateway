defmodule ViberProtocol do
  use GenServer
  alias ViberProtocol.RedisManager
  alias ViberEndpoint

  @event_types ["delivered", "seen", "failed", "subscribed","unsubscribed", "conversation_started"]
  @protocol_config %{auth_token: ""}

# ---- Init functions ----
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.set(Atom.to_string(app_name), @protocol_config)
    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{__MODULE__ => "started"}})
    {:ok, []}
  end

# ---- API ----
  def send_message(%{"contact" => phone} = message_info) do
    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{:message_id => message_id, status: "sending_viber"}})
    DbAgent.ContactsRequests.get_by_phone_number!(phone)
    |> check_and_send_message(message_info)
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

# ---- Send message  function ----
  defp check_and_send_message(nil, message_info), do: end_sending_message(:error, message_info)
  defp check_and_send_message(contact, message_info) do
    end_sending_message(message_info)
    body = %{receiver: contact.viber_id, min_api_version: 1, sender: %{name: "E-Test"},type: "text", text: message}
    ViberEndpoint.request("send_message", body)
    |> check_answer()
    |> check_status(message_info, contact)
  end

  defp check_answer({:error, err} = error), do: error
  defp check_answer({ok, response_map}), do: {response_map.status_message, response_map.message_token}

  defp check_status({"ok", message_token} , message_info, contact) do
    reference = Process.send_after(self(), {:end_sending_message, message_info, message_token}, 10000)
    GenServer.cast(self(), {:add_to_state, %{message_token: message_token, message_id: message_info.message_id,
                                                                           referense: reference}})
  end
  defp check_status({"tooManyRequests", _}, message_info, contact) do
    Process.send_after(self(), {:resend, message_info, contact}, 5000)
  end
  defp check_status(_, message_info, _), do: end_sending_message(:error, message_info)

# ---- Server functions ----
  defp handle_info({:resend, message_info, contact}, state) do
    check_and_send_message(contact, message_info)
    {:noreply, state} #@todo remove from state this message
  end

  defp handle_info({:end_sending_message, message_info}, state) do
    end_sending_message(:error, message_info)
    {:noreply, state}
  end

  defp handle_cast({:add_to_state, info}, _, state), do: {:noreply, [info | state]}

# ---- End sending message functions ----
  defp end_sending_messages(:success, viber_message_id) do
    message_status_info =
      RedisManager.get(message_id)
      |> Map.put(:sending_status, true)

    RedisManager.set(message_id, message_status_info)
    message_status_info
  end

  defp end_sending_messages(:error, message_id) do
    RedisManager.get(message_id)
  end

# ---- Callback function ----
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

# ---- Helper function ----
  def check_phone_number("Phone_number", text, user_id) do
    case String.length(text) == 13 do
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

  defp resend(payload) do
    :ok
  end

end