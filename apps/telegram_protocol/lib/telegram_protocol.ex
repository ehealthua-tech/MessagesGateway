defmodule TelegramProtocol do
  alias TDLib.{Method, Object}
  use GenServer
  alias TelegramProtocol.RedisManager

  @session :demosession
  @api_id Application.get_env(:telegram_protocol, :api_id)
  @api_hash Application.get_env(:telegram_protocol, :api_hash)
  @phone Application.get_env(:telegram_protocol, :phone)
  @protocol_config %{api_id: "", api_hash: "",  phone: "", session_name: "", code: "", password: ""}

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.set(Atom.to_string(app_name), @protocol_config)
    TelegramProtocol.start_telegram_lib
    url = Application.get_env(:telegram_protocol, :elasticsearch_url)
    HTTPoison.post(Enum.join([url, "/log"]), Jason.encode!(%{status: "protocol started"}), [{"Content-Type", "application/json"}])
    {:ok, []}
  end

  def start_telegram_lib() do
    Process.send_after(self(), :start_telegram_lib, 10000)
  end

  def handle_info(:start_telegram_lib, state) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    protocol_config = RedisManager.get(Atom.to_string(app_name))
    state =
      case protocol_config.api_id == "" and
           protocol_config.api_hash == "" and
           protocol_config.phone == "" and
           protocol_config.session_name == "" do
        true->
          start_telegram_lib()
          state
        _ ->
          config = struct(TDLib.default_config(), %{api_id: String.to_integer(protocol_config.api_id), api_hash: protocol_config.api_hash})
          {:ok, _pid} = TDLib.open(String.to_atom(protocol_config.session_name), self(), config)
          {pid, command} = TDLib.transmit(String.to_atom(protocol_config.session_name), "verbose 0")
          {pid, command, protocol_config}
      end
    {:noreply, state}
  end

  #-Authorization---------------------------------------------------------------------------------------------------------
  def handle_info({:recv, %Object.UpdateAuthorizationState{authorization_state: auth_state}}, state) do
    telegram_authorization_process(auth_state, state)
    :io.format("~nstate: ~p~n", [state])
    {:noreply, state}
  end

  def telegram_authorization_process(%Object.AuthorizationStateWaitTdlibParameters{}, state), do: :ignore

  def telegram_authorization_process(%Object.AuthorizationStateWaitEncryptionKey{}, state), do: :ignore

  def telegram_authorization_process(%Object.AuthorizationStateWaitPhoneNumber{}, {pid, command, protocol_config} = state) do
    query = %Method.SetAuthenticationPhoneNumber{
      phone_number: @phone,
      allow_flash_call: false
    }
    TDLib.transmit(String.to_atom(protocol_config.session_name), query)
  end

  def handle_cast({:send_code, payload}, {pid, command, protocol_config} = state) do
    query = %Method.CheckAuthenticationCode{code: payload.code}
    TDLib.transmit(String.to_atom(protocol_config.session_name), query)
    {:noreply, %{messages: payload}}
  end

  def handle_cast({:send_pass, payload}, {pid, command, protocol_config} = state) do
    query = %Method.CheckAuthenticationPassword{password: payload.pass}
    TDLib.transmit(String.to_atom(protocol_config.session_name), query)
    {:noreply, %{messages: payload}}
  end

  def telegram_authorization_process(%Object.AuthorizationStateWaitCode{}, state) do
    :io.format("~n~nPlease authentication code~n~n")
    check_authentication_code()
  end

  defp check_authentication_code() do
    Process.send_after(self(), :check_authentication_code , 5000)
  end

  def handle_info(:check_authentication_code,  state) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    protocol_config = RedisManager.get(Atom.to_string(app_name))
    case String.length(protocol_config.code) > 0 do
      true -> GenServer.cast(__MODULE__, {:send_code, %{code: protocol_config.code}})
      _-> check_authentication_code()
    end
    {:noreply, state}
  end

  def telegram_authorization_process(%Object.AuthorizationStateWaitPassword{}, state) do
    :io.format("~n~nPlease authentication Password~n~n")
    check_authentication_password()
  end

  defp check_authentication_password() do
    Process.send_after(self(), :check_authentication_password , 5000)
  end

  def handle_info(:check_authentication_password,  state) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    protocol_config = RedisManager.get(Atom.to_string(app_name))
    case String.length(protocol_config.password) > 0 do
      true ->  GenServer.cast(__MODULE__, {:send_pass, %{pass: protocol_config.password}})
      _-> check_authentication_password()
    end
    {:noreply, state}
  end

  def telegram_authorization_process(%Object.AuthorizationStateReady{}, state) do
    {:ok, :auth}
  end

  #-Send message-----------------------------------------------------------------------------------------------------------

  def handle_cast({:send_messages, payload, protocol_config},  state) do
    :io.format("~n handle_castpayload: ~p~n", [payload])
    query = %Method.ImportContacts{contacts: [%{phone_number: payload.contact}]}
    TDLib.transmit(String.to_atom(protocol_config.session_name), query)
    {:noreply, Map.put(protocol_config, :messages, payload)}
  end

  def handle_info({:recv, %Object.ImportedContacts{user_ids: [user_ids], importer_count: importer_count}},  %{messages: payload} = state) do
    query = %Method.CreatePrivateChat{user_id: user_ids, force: false}
    if query.user_id == 0 do
      MessagesGateway.RedisManager.del(payload.message_id)
      resend(payload)
    else
      TDLib.transmit(String.to_atom(state.session_name), query)
    end
    {:noreply, state}
  end

  #  def handle_info({:recv, %Object.UpdateMessageSendSucceeded{message: message}},  %{messages: payload} = state) do
  #    :io.format("~nMessage id ~p send~n",[message.id])
  #    :timer.sleep(10000)
  #   query =  %Method.GetMessages{chat_id: message.chat_id, message_ids: [message.id]}
#  TDLib.transmit(state.session_name, query)
  #    {:noreply, state}
  #  end

  def handle_info({:recv, %Object.UpdateChatReadOutbox{chat_id: chat_id, last_read_outbox_message_id: last_read_outbox_message_id}},  %{messages: %{message_id: message_id} = payload} = state) do
    message_info = MessagesGateway.RedisManager.get(payload.message_id)
    MessagesGateway.RedisManager.set(payload.message_id, Jason.encode!(Map.put(message_info, "telegram_sending_status", true)))
    url = Application.get_env(:telegram_protocol, :elasticsearch_url)
    HTTPoison.post(Enum.join([url, "/log/", message_id]), Jason.encode!(%{:status => "sent"}), [{"Content-Type", "application/json"}])
    {:noreply, state}
  end

  def handle_info({:recv, %Object.UpdateChatReadOutbox{}}, state), do: {:noreply, state}

  def handle_info({:recv, %Object.Chat{id: chat_id}},  %{messages: payload} = state) do
    :io.format("~npayload: ~p~n", [payload])
    text = get_in(state, [:messages, :body])
    query = %Method.SendMessage{
      chat_id: chat_id,
      reply_to_message_id: 0,
      disable_notification: false,
      from_background: false,
      input_message_content:
      %Object.InputMessageText{
        text: %Object.FormattedText{
          text: text}, }}
    TDLib.transmit(String.to_atom(state.session_name), query)
    {:noreply, state}
  end

  def handle_info({:recv, %Object.Message{} = info},  state) do
    {:noreply, state}
  end

  def handle_info(info,  state) do
    {:noreply, state}
  end

  #-API-------------------------------------------------------------------------------------------------------------------
  def send_message(payload) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    protocol_config = RedisManager.get(Atom.to_string(app_name))
    GenServer.cast(__MODULE__, {:send_messages, payload, protocol_config})
#    resend_timeout = Application.get_env(:telegram_protocol, :resend_timeout, 30)
#    :timer.sleep(resend_timeout*1000)
#    message_info = MessagesGateway.RedisManager.get(payload.message_id)
#    if Map.get(message_info, "telegram_sending_status", :nil) == true do
#      :ok
#    else
#      MessagesGateway.RedisManager.del(payload.message_id)
#      resend(payload)
#    end
  end

  def send_code(%{"code" => code} = payload) do
    GenServer.cast(__MODULE__, {:send_code, %{code: code}})
  end

  def send_pass(%{"pass" => pass} = payload) do
    GenServer.cast(__MODULE__, {:send_pass, %{pass: pass}})
  end

  defp resend(payload) do
    priority_list = payload.priority_list
    if priority_list != [] do
      selected_operator = Enum.min_by(priority_list, fn e -> e.priority end)
      operator_type_id = selected_operator.operator_type_id
      new_priority_list = List.delete(priority_list, operator_type_id)
      TelegramProtocol.MqManager.send_to_operator(Jason.encode!(Map.put(payload, :priority_list, new_priority_list)), operator_type_id)
    else
      :callback_failed
    end

  end

  end
