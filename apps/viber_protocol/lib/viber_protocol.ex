defmodule ViberProtocol do
  use GenServer
  alias ViberProtocol.RedisManager
  alias ViberEndpoint

  @event_types ["delivered", "seen", "failed", "subscribed","unsubscribed", "conversation_started"]
  @protocol_config %{module_name: __MODULE__, method_name: :send_message}

  @spec start_link() :: result when
          result: {:ok, pid()} | :ignore | {:error, {:already_started, pid()} | {:shutdown, term()} | term()}

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(opts) :: result when
          opts: term(),
          result: {:ok, []}

  def init(_opts) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.set(Atom.to_string(app_name), @protocol_config)
    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{__MODULE__ => "started"}})
    {:ok, []}
  end

  @spec send_message(map()) :: pid() | {pid(), reference()} | reference() | :ok

  def send_message(%{contact: phone, message_id: message_id} = message_info) do
    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{:message_id => message_id, status: "sending_viber"}})
    DbAgent.ContactsRequests.get_by_phone_number!(phone)
    |> check_and_send_message(message_info)
  end

  @spec callback_response(map()) :: :ok

  def callback_response(%{body_params: body}) do
    event = Map.get(body, "event")
    GenServer.cast(__MODULE__, {event, body})
  end

  @spec set_webhook(String.t()) :: {:ok, term()}

  def set_webhook(url)do
    body = %{url: url, event_types: @event_types, send_name: true, send_photo: true}
    ViberEndpoint.request("set_webhook", body)
  end

  @spec check_and_send_message(map() | nil, map()) :: pid() | {pid(), reference()} | reference() | :ok

  defp check_and_send_message(nil, message_info), do: spawn(ViberProtocol, :end_sending_message, [:error, message_info.message_id])
  defp check_and_send_message(contact, %{body: message} = message_info) do
    body = %{receiver: contact.viber_id, min_api_version: 1, sender: %{name: "E-Test"},type: "text", text: message}
    ViberEndpoint.request("send_message", body)
    |> check_answer()
    |> check_status(message_info, contact)
  end

  @spec check_answer({:error, term()} | {:ok, term()}) :: term() | {String.t(), String.t()}

  defp check_answer({:error, err} = error), do: error
  defp check_answer({ok, response_map}), do: {response_map.status_message, response_map.message_token}

  @spec check_status({String.t(), String.t()}, map(), map()) :: pid() | {pid(), reference()} | reference() | :ok

  defp check_status({"ok", message_token} , message_info, contact) do
    reference = Process.send_after( __MODULE__, {:end_sending_message, message_token}, 10000)
    GenServer.cast(__MODULE__, {:add_to_state, %{message_token: message_token, message_id: message_info.message_id,
      reference: reference}})
  end
  defp check_status({"tooManyRequests", _}, message_info, contact) do
    Process.send_after( __MODULE__, {:resend, message_info, contact}, 5000)
  end
  defp check_status(_, message_info, _), do: spawn(ViberProtocol, :end_sending_message, [:error, message_info.message_id])

  @spec handle_info(msg, state) :: result when
          msg: :timeout | term(),
          state: term(),
          result:  {:noreply, []} | {:noreply, [], timeout() | :hibernate | {:continue, term()}} | {:stop, term(), term()}

  def handle_info({:resend, message_info, contact}, state) do
    check_and_send_message(contact, message_info)
    {:noreply, state}
  end

  def handle_info({:end_sending_message, message_token}, state) do
    message_info = Enum.find(state, fn x -> Map.get(x, :message_token, :nil) == message_token end)
    new_state = List.delete(state, message_info)
    spawn(ViberProtocol, :end_sending_message, [:error, message_info.message_id])
    {:noreply, new_state}
  end

  @spec handle_cast(request :: term(), state :: term()) ::
          {:noreply, new_state}
          | {:noreply, new_state, timeout() | :hibernate | {:continue, term()}}
          | {:stop, reason :: term(), new_state}
        when new_state: term()

  def handle_cast({"webhook", body}, state), do: {:noreply, state}

  def handle_cast({"seen", %{"message_token" => message_token} = body}, state) do
    new_state =
    Enum.find(state, fn x -> Map.get(x, :message_token, :nil) == message_token end)
    |> remove_message_from_state(state)
    {:noreply, new_state}
  end

  @spec remove_message_from_state(any(), term()) :: term() | list()

  defp remove_message_from_state(nil, state), do: state
  defp remove_message_from_state(message_info, state) do
    Process.cancel_timer(message_info.reference)
    spawn(ViberProtocol, :end_sending_message, [:success, message_info.message_id])
    List.delete(state, message_info)
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
  def handle_cast(info, state), do:  {:noreply, state}

  @spec end_sending_message(any(), :nil | String.t()) :: :ok | any()

  def end_sending_message(_, :nil), do: :ok
  def end_sending_message(:success, message_id) do
    message_status_info =
      RedisManager.get(message_id)
      |> Map.put(:sending_status, "read")
    RedisManager.set(message_id, message_status_info)
    {:ok, app_name} = :application.get_application(__MODULE__)
    protocol =  RedisManager.get(Atom.to_string(app_name))
    apply(String.to_atom(protocol.module_name), String.to_atom(protocol.method_name), [%{message_id: message_id}])
  end

  def end_sending_message(:error, message_id) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    protocol =  RedisManager.get(Atom.to_string(app_name))
    apply(String.to_atom(protocol.module_name), String.to_atom(protocol.method_name), [%{message_id: message_id}])
  end


# ---- Helper function ----

 # @spec check_phone_number(String.t(), String.t(), String.t()) :: {:ok, map()} | {:error, map()}

  def check_phone_number("Phone_number", phone_number, user_id) when byte_size(phone_number) == 13 do
    String.slice(phone_number, 1, 11)
    |> String.to_integer()
    |> add_viber_id(%{phone_number: phone_number, viber_id: user_id})
  end

 # @spec add_viber_id(binary(), map()) :: {:ok, map()} | {:error, map()}

  defp add_viber_id(number, map) when is_integer(number), do: DbAgent.ContactsRequests.add_viber_id(map)

end