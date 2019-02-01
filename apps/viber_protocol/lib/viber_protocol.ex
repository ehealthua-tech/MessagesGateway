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
  def send_message(%{contact: phone, message_id: message_id} = message_info) do
    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{:message_id => message_id, status: "sending_viber"}})
    DbAgent.ContactsRequests.get_by_phone_number!(phone)
    |> check_and_send_message(message_info)
  end

  def callback_response(%{body_params: body}) do
    :io.format("~nbody: ~p~n", [body])
    event = Map.get(body, "event")
    GenServer.cast(__MODULE__, {event, body})
  end

  def set_webhook(url)do
    body = %{url: url, event_types: @event_types,
      send_name: true, send_photo: true}
    ViberEndpoint.request("set_webhook", body)
  end

# ---- Send message  function ----
  defp check_and_send_message(nil, message_info), do: end_sending_message(:error, message_info)
  defp check_and_send_message(contact, %{body: message} = message_info) do
    body = %{receiver: contact.viber_id, min_api_version: 1, sender: %{name: "E-Test"},type: "text", text: message}
    ViberEndpoint.request("send_message", body)
    |> check_answer()
    |> check_status(message_info, contact)
  end

  defp check_answer({:error, err} = error), do: error
  defp check_answer({ok, response_map}), do: {response_map.status_message, response_map.message_token}

  defp check_status({"ok", message_token} , message_info, contact) do
    :io.format("~nmessage_token: ~p~n", [message_token])
    reference = Process.send_after( __MODULE__, {:end_sending_message, message_token}, 10000)
    :io.format("~nreference: ~p~n", [reference])
    GenServer.cast(__MODULE__, {:add_to_state, %{message_token: message_token, message_id: message_info.message_id,
      reference: reference}})
  end
  defp check_status({"tooManyRequests", _}, message_info, contact) do
    Process.send_after( __MODULE__, {:resend, message_info, contact}, 5000)
  end
  defp check_status(_, message_info, _), do: end_sending_message(:error, message_info)

# ---- Server functions ----
  def handle_info({:resend, message_info, contact}, state) do
    check_and_send_message(contact, message_info)
    {:noreply, state}
  end

  def handle_info({:end_sending_message, message_token}, state) do
    message_info = Enum.find(state, fn x -> Map.get(x, :message_token, :nil) == message_token end)
    new_state = List.delete(state, message_info)
    end_sending_message(:error, message_info.message_id)
    {:noreply, new_state}
  end

  def handle_cast({"webhook", body}, state), do: {:noreply, state}

  def handle_cast({"seen", %{"message_token" => message_token} = body}, state) do
    message_info = Enum.find(state, fn x -> Map.get(x, :message_token, :nil) == message_token end)
    Process.cancel_timer(message_info.reference)
    new_state = List.delete(state, message_info)
    end_sending_message(:success,  message_info)
    {:noreply, new_state}
  end

  def handle_cast({"delivered", body}, state), do: {:noreply, state}

  def handle_cast({"conversation_started", body}, state) do
    id = get_in(body, ["user", "id"])
    body = %{receiver: id, min_api_version: 1, sender: %{name: "E-Test", avatar: "http://avatar.example.com"},
      tracking_data: "Phone_number", type: "text", text: "Щоб отримувати повідомлення, будь ласка,
          увімкніть діалог(в меню інформація) та введіть Ваший номер телефону у форматі +380ххххххххх"}
    {:ok, _} = ViberEndpoint.request("send_message", body)
    {:noreply, state}
  end

  def handle_cast({"message", body}, state) do
    message = get_in(body, ["message"])
    tracking_data = get_in(message, ["tracking_data"])
    text = get_in(message, ["text"])

    sender  = get_in(body, ["sender"])
    user_id = get_in(sender, ["id"])

    check_phone_number(tracking_data, text, user_id)
    {:noreply, state}
  end

  def handle_cast({"subscribed", body}, state) do
    id = get_in(body, ["user", "id"])
    body = %{receiver: id, min_api_version: 1, sender: %{name: "E-Test", avatar: "http://avatar.example.com"},
      tracking_data: "Phone_number", type: "text", text: "Щоб отримувати повідомлення, будь ласка,
          увімкніть діалог(в меню інформація) та введіть Ваший номер телефону у форматі +380ххххххххх"}
    {:ok, _} = ViberEndpoint.request("send_message", body)
    {:noreply, state}
  end

  def handle_cast({:add_to_state, info}, state), do: {:noreply, [info | state]}
  def handle_cast(info, state) do
    :io.format("~ninfo: ~p~n", [info])
    {:noreply, state}
  end



  # ---- End sending message functions ----
  defp end_sending_message(_, :nil), do: :ok
  defp end_sending_message(:success, %{message_id: message_id}) do
    message_status_info =
      RedisManager.get(message_id)
      |> Map.put(:sending_status, true)
    RedisManager.set(message_id, message_status_info)
    message_status_info
  end

  defp end_sending_message(:error, message_id) do
    message_id
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

end