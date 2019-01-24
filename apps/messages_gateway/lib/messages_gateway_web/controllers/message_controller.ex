defmodule MessagesGatewayWeb.MessageController do
  use MessagesGatewayWeb, :controller
  alias MessagesGateway.UUID
  alias MessagesGateway.Prioritization

  @sending_start_status true
  @status_not_send false

  action_fallback(MessagesGatewayWeb.FallbackController)

#  ---- send a message to the client any available way ------------------------

  def new_message(conn, %{"resource" => resource}) do
    with {:ok, priority_list} <- Prioritization.get_message_priority_list(),
         {:ok, message_id} <- add_to_db_and_queue(resource, priority_list)
      do
      url = Application.get_env(:messages_gateway, :elasticsearch_url)
      HTTPoison.post(Enum.join([url, "/log/", message_id]), Jason.encode!(resource), [{"Content-Type", "application/json"}])
      render(conn, "index.json", message_id: message_id)
    end
  end

#  ---- send a message to the client only by SMS way --------------------------

  def new_sms(conn, %{"resource" => resource}) do
    with {:ok, priority_list} <- Prioritization.get_message_priority_list(),
         {:ok, message_id} <- add_to_db_and_queue(resource, priority_list)
      do
      url = Application.get_env(:messages_gateway, :elasticsearch_url)
      HTTPoison.post(Enum.join([url, "/log/", message_id]), Jason.encode!(resource), [{"Content-Type", "application/json"}])
      render(conn, "index.json", %{message_id: message_id})
    end

  end

#  ---- send only e-mail ------------------------------------------------------

  def new_email(conn, %{"resource" => %{"email" => email, "body" => body, "subject" => subject} = resource}) do
    with {:ok, priority_list} <- Prioritization.get_smtp_priority_list(),
         {:ok, message_id} <- add_email_to_db_and_queue(email, body, subject, priority_list)
      do
      url = Application.get_env(:messages_gateway, :elasticsearch_url)
      HTTPoison.post(Enum.join([url, "/log/", message_id]), Jason.encode!(resource), [{"Content-Type", "application/json"}])
      render(conn, "index.json", %{message_id: message_id})
    end

  end

  #  ---- get messages queue size ------------------------------------------------------

  def queue_size(conn, _resource) do
    with {:ok, queue_size} = GenServer.call(MessagesGateway.MqManager, :queue_size)
      do
      render(conn, "queue_size.json", %{queue_size: queue_size})
    end

  end

# ---- Check message status ---------------------------------------------------------

  def message_status(conn, %{"resource" => %{"message_id" => message_id}}) do
    with message_info <- MessagesGateway.RedisManager.get(message_id)
      do
      render(conn, "message_status.json", message_id: message_id, message_status: message_info.sending_status)
    end
  end

# ---- Change message status ---------------------------------------------------------

  def change_message_status(conn, %{"resource" => %{"message_id" => message_id, "sending_active" => active}}) do
    with {:ok, json_body} <- Jason.encode(%{sending_status: active}),
          :ok <- MessagesGateway.RedisManager.set(message_id, json_body)
      do
      render(conn, "message_change_status.json", %{sending_status: active})
    end

  end

# ---- Help functions ---------------------------------------------------------

  def add_to_db_and_queue( %{"contact" => phone, "body" => body} = resource, priority_list) do
    with {:ok, message_id} <- UUID.generate_uuid(),
         :ok <- add_to_redis(message_id, %{active: @sending_start_status, sending_status: @status_not_send}),
         :ok <- add_to_message_queue(message_id, %{message_id: message_id, contact: phone, body: body,
           callback_url: Map.get(resource, "callback_url", ""), priority_list: priority_list})
      do
        {:ok, message_id}
    end
  end

  def add_email_to_db_and_queue(contact, body, subject, priority_list) do
    with {:ok, message_id} <- UUID.generate_uuid(),
         :ok <- add_to_redis(message_id, %{active: @sending_start_status, sending_status: @status_not_send}),
         :ok <- add_to_message_queue(message_id, %{message_id: message_id, contact: contact, body: body, callback_url: "",
           priority_list: priority_list, subject: subject})
      do
      {:ok, message_id}
    end
  end

  def add_to_redis(message_id, body) do
    MessagesGateway.RedisManager.set(message_id, body)
    url = Application.get_env(:messages_gateway, :elasticsearch_url)
    HTTPoison.post(Enum.join([url, "/log_messages_gateway/log/", message_id]), Jason.encode!(%{message_id: message_id, status: "add_to_redis"}), [{"Content-Type", "application/json"}])
    :ok
  end

  def add_to_message_queue(message_id, body) do
    Jason.encode!(body)
    |> MessagesGateway.MqManager.publish()
  end

end