defmodule TelegramApi do
  alias TDLib.{Method, Object}
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
  @session :demosession
  @api_id Application.get_env(:telegram_protocol, :api_id)
  @api_hash Application.get_env(:telegram_protocol, :api_hash)
  @phone Application.get_env(:telegram_protocol, :phone)

  def init(_opts) do
    config = struct(TDLib.default_config(), %{api_id: @api_id, api_hash: @api_hash})
    {:ok, _pid} = TDLib.open(@session, self(), config)
    {:ok, TDLib.transmit(@session, "verbose 0")}
  end
#-Authorization---------------------------------------------------------------------------------------------------------
  def handle_info({:recv, %Object.UpdateAuthorizationState{authorization_state: auth_state}}, state) do
    telegram_authorization_process(auth_state)
    {:noreply, state}
  end

  def telegram_authorization_process(%Object.AuthorizationStateWaitTdlibParameters{}), do: :ignore

  def telegram_authorization_process(%Object.AuthorizationStateWaitEncryptionKey{}), do: :ignore

  def telegram_authorization_process(%Object.AuthorizationStateWaitPhoneNumber{}) do
    query = %Method.SetAuthenticationPhoneNumber{
      phone_number: @phone,
      allow_flash_call: false
    }
    TDLib.transmit(@session, query)
  end

  def handle_cast({:send_pass, payload},  state) do
    query = %Method.CheckAuthenticationCode{code: payload.pass}
    TDLib.transmit(@session, query)
    {:noreply, %{messages: payload}}
  end

#  def telegram_authorization_process(%Object.AuthorizationStateWaitCode{}) do
#    code = IO.gets("Please authentication code: ") |> String.trim()
#    query = %Method.CheckAuthenticationCode{code: code}
#    TDLib.transmit(@session, query)
#  end

  def telegram_authorization_process(%Object.AuthorizationStateWaitPassword{}) do
    pass = IO.gets("Please authentication pass: ") |> String.trim()
    query = %Method.CheckAuthenticationPassword{password: pass}
    TDLib.transmit(@session, query)
  end
  def telegram_authorization_process(%Object.AuthorizationStateReady{}) do
    {:ok, :auth}
  end

#-Send message-----------------------------------------------------------------------------------------------------------

  def handle_cast({:send_messages, payload},  state) do
    query = %Method.ImportContacts{contacts: [%{phone_number: payload.contact}]}
    TDLib.transmit(@session, query)
    {:noreply, %{messages: payload}}
  end

  def handle_info({:recv, %Object.ImportedContacts{user_ids: [user_ids], importer_count: importer_count}},  %{messages: payload} = state) do
    query =%Method.CreatePrivateChat{user_id: user_ids, force: false}
    if Map.get(query, :user_id) == 0 do
      :io.format("User not found")
      resend(payload)
    else
      TDLib.transmit @session, query
    end
    {:noreply, state}
  end

  def handle_info({:recv, %Object.UpdateMessageSendSucceeded{message: message}},  %{messages: payload} = state) do
    redis_command(["SETEX", message.id, 20, "delivered"])
    :io.format("~nMessage id ~p send~n",[message.id])
    {:noreply, state}
  end

  def handle_info({:recv, %Object.UpdateChatReadOutbox{chat_id: chat_id, last_read_outbox_message_id: last_read_outbox_message_id}},  %{messages: payload} = state) do
    :io.format("~nMessage ~p was read~n",[ 	last_read_outbox_message_id])
    redis_command(["SETEX", last_read_outbox_message_id, 30,"read"])
    {:noreply, state}
  end

  def handle_info({:recv, %Object.Chat{id: chat_id}},  state) do
    text = get_in(state, [:messages, :body])
    query = %Method.SendMessage{
      chat_id: chat_id,
      reply_to_message_id: 0,
      disable_notification: false,
      from_background: false,
      input_message_content:
      %Object.InputMessageText{
        text: %Object.FormattedText{
          text: text} }}
    TDLib.transmit @session, query
    {:noreply, state}
  end

  def handle_info({:recv, %Object.Message{}},  state) do
    {:noreply, state}
  end

  def handle_info(info,  state) do
    {:noreply, state}
  end

#-API-------------------------------------------------------------------------------------------------------------------
  def send_message(payload) do
    :io.format("~nTELEGRAM API~n")
    GenServer.cast(__MODULE__, {:send_messages, payload})
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
      TelegramSubscriber.send_to_operator(Jason.encode!(Map.put(payload, :priority_list, new_priority_list)), operator_type_id)
    else
      :callback_failed
    end

  end

  defp redis_command(command) do
    pool_size = Application.get_env(:messages_gateway,  MessagesGateway.RedisManager)[:pool_size]
    connection_index = rem(System.unique_integer([:positive]), pool_size)
    Redix.command(:"redis_#{connection_index}", command)
end

end
