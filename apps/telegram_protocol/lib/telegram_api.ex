defmodule TelegramApi do
  alias TDLib.{Method, Object}
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
  @session :demosession
  @api_id Application.get_env(:telegram_protocol, :api_id)
  @api_hash Application.get_env(:telegram_protocol, :api_hash)

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
    phone_number = IO.gets("Please provide phone number: ") |> String.trim
    query = %Method.SetAuthenticationPhoneNumber{
      phone_number: phone_number,
      allow_flash_call: false
    }
    TDLib.transmit @session, query
  end

  def telegram_authorization_process(%Object.AuthorizationStateWaitCode{}) do
    code = IO.gets("Please authentication code: ") |> String.trim()
    query = %Method.CheckAuthenticationCode{code: code}
    TDLib.transmit(@session, query)
  end

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

  def handle_info({:recv, %Object.ImportedContacts{user_ids: [user_ids], importer_count: importer_count}},  state) do
    query =%Method.CreatePrivateChat{user_id: user_ids, force: false}
    TDLib.transmit @session, query
    {:noreply, state}
  end

  def handle_info({:recv, %Object.Chat{id: chat_id}},  state) do
    text = get_in(state, [:messages, :body])
    query =%Method.SendMessage{
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
    :io.format("~nTelegram answer:~p~n",[state])
    {:noreply, state}
  end

  def handle_info(_info,  state) do
    {:noreply, state}
  end

#-API-------------------------------------------------------------------------------------------------------------------
  def send_message(%{"contact" => phone, "body" => message} = payload) do
    :io.format("~nTELEGRAM API~n")
    GenServer.cast(__MODULE__, {:send_messages, %{body: body, contact: contact }})
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
