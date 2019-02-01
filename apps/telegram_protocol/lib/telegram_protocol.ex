defmodule TelegramProtocol do
  alias TDLib.{Method, Object}
  use GenServer
  alias TelegramProtocol.RedisManager

  @authentication_timeout 5000
  @protocol_config %{api_id: "", api_hash: "",  phone: "", session_name: "", code: "", password: "", module_name: __MODULE__, method_name: :send_message}

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.set(Atom.to_string(app_name), @protocol_config)
    TelegramProtocol.start_telegram_lib
    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{__MODULE__ => "started"}})
    {:ok, []}
  end

  def start_telegram_lib() do
    Process.send_after(self(), :start_telegram_lib, 10000)
  end

  def handle_info(:start_telegram_lib, state) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.get(Atom.to_string(app_name))
    |> check_config()
    {:noreply, state}
  end

  defp check_config({:error, _}), do: start_telegram_lib()
  defp check_config(%{api_id: api_id, api_hash: api_hash, phone: phone, session_name: session_name} = protocol_config)
       when api_id == "" and api_hash == "" and phone == "" and session_name == ""
    do
    start_telegram_lib()
  end

  defp check_config(protocol_config) do
    config = struct(TDLib.default_config(), %{api_id: String.to_integer(protocol_config.api_id), api_hash: protocol_config.api_hash})
    {:ok, _pid} = TDLib.open(String.to_atom(protocol_config.session_name), self(), config)
    {_pid, _command} = TDLib.transmit(String.to_atom(protocol_config.session_name), "verbose 0")
  end

  #-Authorization process------------------------------------------------------

  def handle_info({:recv, %Object.UpdateAuthorizationState{authorization_state: auth_state}}, state) do
    telegram_authorization_process(auth_state)
    {:noreply, state}
  end

  def telegram_authorization_process(%Object.AuthorizationStateWaitTdlibParameters{}), do: :ignore

  def telegram_authorization_process(%Object.AuthorizationStateWaitEncryptionKey{}), do: :ignore

  def telegram_authorization_process(%Object.AuthorizationStateWaitPhoneNumber{}) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    protocol_config = RedisManager.get(Atom.to_string(app_name))
    query = %Method.SetAuthenticationPhoneNumber{
      phone_number: protocol_config.phone,
      allow_flash_call: false
    }
    TDLib.transmit(String.to_atom(protocol_config.session_name), query)
  end

  # Telegram send to you code and if you enter it in config Authorization process will continue
  def telegram_authorization_process(%Object.AuthorizationStateWaitCode{}), do: check_authentication_code()

  # If you select 2 factor authorization you need add password to config
  def telegram_authorization_process(%Object.AuthorizationStateWaitPassword{}), do: check_authentication_password()

  def telegram_authorization_process(%Object.AuthorizationStateReady{}), do: {:ok, :auth}


  # For select code and password from config starting cron task which will be work every 'authentication_timeout' microsec
  defp check_authentication_code(), do: Process.send_after(self(), :check_authentication_code , @authentication_timeout)
  defp check_authentication_password(), do: Process.send_after(self(), :check_authentication_password , @authentication_timeout)

  def handle_info(:check_authentication_code,  state) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.get(Atom.to_string(app_name))
    |> send_code()

    {:noreply, state}
  end

  def handle_info(:check_authentication_password,  state) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.get(Atom.to_string(app_name))
    |> send_password()

    {:noreply, state}
  end

  defp send_code({:error, _}), do: check_authentication_code()
  defp send_code(%{code: code}) when code == "", do: check_authentication_code()
  defp send_code(protocol_config) do
    query = %Method.CheckAuthenticationCode{code: protocol_config.code}
    TDLib.transmit(String.to_atom(protocol_config.session_name), query)
  end

  defp send_password({:error, _}), do: check_authentication_password()
  defp send_password(%{password: password}) when password == "", do: check_authentication_password()
  defp send_password(protocol_config) do
    query = %Method.CheckAuthenticationCode{code: protocol_config.password}
    TDLib.transmit(String.to_atom(protocol_config.session_name), query)
  end

  #-Sending message------------------------------------------------------------

  # Importing contacts to our contact
  def handle_cast({:send_messages, payload},  state) do
    query = %Method.ImportContacts{contacts: [%{phone_number: payload.contact}]}
    do_query(query)

    # if user number not fount in telegram or timeout will be more than 20 sec we canceled sending
    # and use for send another operator
    reference = Process.send_after(self(), {:error_sending_messages, payload.message_id}, 20000)

    new_state = [%{phone_number: payload.contact, message_id: payload.message_id, reference_create_account: reference} | state]
    {:noreply, new_state}
  end

  # Creating private chat with importing contact (if it does not have telegram user id will be 0 and we send payload to messages router )
  def handle_info({:recv, %Object.ImportedContacts{user_ids: [user_ids]}}, state) do
    select_user_info(user_ids, state)
    {:noreply, state}
  end

  def select_user_info(0, state), do: :ignore
  def select_user_info(user_id) do
    query = %Method.GetUser{user_id: user_id}
    do_query(query)
  end

  # Creating private chat with importing contact (if it does not have telegram user id will be 0 and we send payload to messages router )
  def handle_info({:recv, %Object.User{id: user_id, phone_number: contact, status: status, is_verified: is_verified, type: user_type} = userinfo}, state) do
    :io.format("~nuserinfo: ~p~n", [userinfo])
    new_state = create_chat(user_id, contact, is_verified, user_type, state)
    {:noreply, new_state}
  end

  defp create_chat(_, _,  false, user_type, state) when
         user_type == %Object.UserTypeDeleted{} or
         user_type == %Object.UserTypeBot{} or
         user_type == %Object.UserTypeUnknown{}
  do
    state
  end

  defp create_chat(user_id, contact, _, user_type, state) do
    {[state_info], old_state} = Enum.split_while(state, fn x -> x.phone_number == contact end)
    Process.cancel_timer(state_info.reference_create_account)
    reference = Process.send_after(self(), {:error_sending_messages, state_info.message_id}, 30000)
    new_state = %{user_id: user_id, phone_number: contact, message_id: state_info.message_id, error_reference: reference}
    query = %Method.CreatePrivateChat{user_id: user_id, force: false}
    do_query(query)
    [new_state | old_state]
  end

  # Select chat id and send message
  def handle_info({:recv, %Object.Chat{id: chat_id}},  %{messages: payload} = state) do
    text = get_in(state, [:messages, :body])
    query = %Method.SendMessage{
      chat_id: chat_id,
      reply_to_message_id: 0,
      disable_notification: false,
      from_background: true,
      input_message_content:
      %Object.InputMessageText{
        text: %Object.FormattedText{
          text: text}, }}
    do_query(query)
    {:noreply, state}
  end

  # if user read message we selected UpdateChatReadOutbox
  def handle_info({:recv, %Object.UpdateChatReadOutbox{chat_id: chat_id}}, state) do
    query = %Method.SearchChatMembers{chat_id: chat_id, query: "", limit: 200}
    do_query(query)
    {:noreply, state}
  end

  # select members from chat and cancel cron task
  def handle_info({:recv, %Object.ChatMembers{members: member} = info},  state) do
    :io.format("~nmembers: ~p~n", [member])
    {[state_info], old_state} = Enum.split_while(state, fn x -> x.user_id == member.id end)
    Process.cancel_timer(state_info.error_reference)
    spawn(TelegramProtocol, :end_sending_messages, [:success, state_info.message_id])
    {:noreply, old_state}
  end

  # if we have some error remove this messages from state and ending sending it
  def handle_info({:error_sending_messages, message_id}, state) do
    {_, old_state} = Enum.split_while(state, fn x -> x.message_id == message_id end)
    spawn(TelegramProtocol, :end_sending_messages, [:error, message_id])
    {:noreply, old_state}
  end

  def handle_info(info,  state) do
    {:noreply, state}
  end

  defp do_query(query) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    protocol_config = RedisManager.get(Atom.to_string(app_name))
    TDLib.transmit(String.to_atom(protocol_config.session_name), query)
  end

  #-API------------------------------------------------------------------------
  def send_message(%{message_id: message_id} = payload) do
    :io.format(payload)
    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{:message_id => message_id, status: "sending_telegram"}})
    {:ok, app_name} = :application.get_application(__MODULE__)
    protocol_config = RedisManager.get(Atom.to_string(app_name))
    GenServer.cast(__MODULE__, {:send_messages, payload})
  end

  #-check status of message and return result ---------------------------------
  defp end_sending_messages(:success, message_id) do
    message_status_info =
      RedisManager.get(message_id)
      |> Map.put(:sending_status, true)

    RedisManager.set(message_id, message_status_info)
    apply(:'Elixir.MessagesRouter', :send_message, [%{message_id: message_id}])
  end

  defp end_sending_messages(:error, message_id) do
    RedisManager.get(message_id)
    apply(:'Elixir.MessagesRouter', :send_message, [%{message_id: message_id}])
  end

end
