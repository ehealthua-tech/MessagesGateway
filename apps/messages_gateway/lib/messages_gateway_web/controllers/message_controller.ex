defmodule MessagesGatewayWeb.MessageController do
  use MessagesGatewayWeb, :controller
  alias MessagesGateway.UUID
  alias MessagesGateway.Prioritization

  @sending_start_status true
  @status_not_send false

  action_fallback(MessagesGatewayWeb.FallbackController)

#  ---- send a message to the client any available way ------------------------

  def new_message(conn, %{"resource" => %{"request_id" => request_id, "contact" => contact, "body" => body} = resource}) do
    with {:ok, priority_list} <- Prioritization.get_priority_list(""),
         {:ok, message_id} <- add_to_db_and_queue(request_id, contact, body, priority_list)
      do
      render(conn, "index.json", request_id: request_id, message_id: message_id)
    end
  end

  def new_message(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end

#  ---- send a message to the client only by SMS way --------------------------

  def new_sms(conn, %{"resource" => %{"request_id" => request_id, "phone" => phone, "body" => body} = resource}) do
    with {:ok, priority_list} <- Prioritization.get_priority_list(),
         {:ok, message_id} <- add_to_db_and_queue(resource, priority_list)
      do
      render(conn, "index.json", request_id: request_id, message_id: message_id)
    end

  end

  def new_sms(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end

#  ---- send only e-mail ------------------------------------------------------

  def new_email(conn, %{"resource" => %{"request_id" => request_id, "email" => email, "body" => body, "subject" => subject} = resource}) do
    with {:ok, priority_list} <- Prioritization.get_priority_list(),
         {:ok, message_id} <- add_email_to_db_and_queue(request_id, email, body, priority_list)
      do
      render(conn, "index.json", request_id: request_id, message_id: message_id)
    end

  end

  def new_email(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end

# ---- Check message status ---------------------------------------------------------

  def message_status(conn, %{"resource" => %{"request_id" => request_id, "message_id" => message_id}}) do
    with message_info <- MessagesGateway.RedisManager.get(message_id)
      do
      render(conn, "message_status.json", request_id: request_id, message_id: message_id, message_status: message_info.sending_status)
    end
  end

  def message_status(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end

# ---- Change message status ---------------------------------------------------------

  def change_message_status(conn, %{"resource" => %{"request_id" => request_id, "message_id" => message_id, "sending_active" => active}}) do
    with {:ok, json_body} <- Jason.encode(%{sending_status: active}),
          :ok <- MessagesGateway.RedisManager.set(message_id, json_body)
      do
      render(conn, "message_change_status.json", %{sending_status: active})
    end

  end

  def change_message_status(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end

# ---- Help functions ---------------------------------------------------------

  def add_to_db_and_queue( %{"request_id" => request_id, "phone" => phone, "body" => body} = resource, priority_list) do
    with {:ok, message_id} <- UUID.generate_uuid(),
         :ok <- add_to_redis(message_id, %{active: @sending_start_status, sending_status: @status_not_send}),
         :ok <- add_to_message_queue(message_id, %{message_id: message_id, contact: phone, body: body,
           callback_url: Map.get(resource, "callback_url", ""), priority_list: priority_list})
      do
        {:ok, message_id}
    end
  end

  def add_email_to_db_and_queue(request_id, contact, body, subject) do
    with {:ok, message_id} <- UUID.generate_uuid(),
         :ok <- add_to_redis(message_id, %{active: @sending_start_status, sending_status: @status_not_send}),
         :ok <- add_to_message_queue(message_id, %{message_id: message_id, contact: contact, body: body, callback_url: "",
           subject: subject})
      do
      {:ok, message_id}
    end
  end

  def add_to_redis(message_id, body) do
    redis_body = Jason.encode!(body)
    MessagesGateway.RedisManager.set(message_id, redis_body)
  end

  def add_to_message_queue(message_id, body) do
    Jason.encode!(body)
    |> MessagesGateway.MqManager.publish()
  end

end