defmodule MessagesGatewayWeb.MessageController do
  use MessagesGatewayWeb, :controller
  alias MessagesGateway.UUID
  alias MessagesGateway.Prioritization

  @sending_start_status true
  @status_not_send false

  action_fallback(MessagesGatewayWeb.FallbackController)

  #  ---- Types ---------------------------------------------------------------
  @typep conn()           :: Plug.Conn.t()
  @typep result()         :: Plug.Conn.t()

  @type message_request_body_with_callback() :: %{"contact": String.t(), "body": String.t(), "callback_url": String.t()}
  @type message_request_body_without_callback() :: %{"contact": String.t(), "body": String.t()}
  @type message_request_body() ::  message_request_body_without_callback() | message_request_body_with_callback()
  @type message_request() :: %{"resource": message_request_body()}

  @type email_request_body() :: %{"email": String.t(), "body": String.t(), "subject": String.t()}
  @type email_request :: %{"resource": email_request_body}

  @type check_status_request_body() :: %{"message_id": String.t()}
  @type check_status_request() :: %{"resource": check_status_request_body()}

  @type change_status_request_body() :: %{"message_id": String.t()}
  @type change_status_request() :: %{"resource": change_status_request_body()}

  #  ---- send a message to the client any available way ----------------------

  @spec new_message(conn, new_message_params) :: result when
          conn: conn(),
          new_message_params: message_request(),
          result: result()

  def new_message(conn, %{"resource" => %{"contact" => contact, "body" => body} = resource}) do
    with {:ok, priority_list} <- Prioritization.get_message_priority_list(),
         {:ok, message_id} <- add_to_db_and_queue(resource, priority_list)
      do
      render(conn, "index.json", message_id: message_id)
    end
  end

#  ---- send only e-mail ------------------------------------------------------

  @spec new_email(conn, new_email_params) :: result when
          conn:   conn(),
          new_email_params: email_request(),
          result: result()

  def new_email(conn, %{"resource" => %{"email" => email, "body" => body, "subject" => subject} = resource}) do
    with {:ok, priority_list} <- Prioritization.get_smtp_priority_list(),
         {:ok, message_id} <- add_email_to_db_and_queue(email, body, subject, priority_list)
      do
      render(conn, "index.json", %{message_id: message_id})
    end

  end

  #  ---- get messages queue size ------------------------------------------------------

  @spec queue_size(conn, _params) :: result when
          conn:   conn(),
          _params: any(),
          result: result()

  def queue_size(conn, _resource) do
    with {:ok, queue_size, datetime} = GenServer.call(MessagesGateway.MqManager, :queue_size)
      do
      render(conn, "queue_size.json", %{queue_size: queue_size, date_time: datetime})
    end

  end

# ---- Check message status ---------------------------------------------------------

  @spec message_status(conn, message_status_params) :: result when
          conn:   conn(),
          message_status_params: check_status_request(),
          result: result()

  def message_status(conn, %{"resource" => %{"message_id" => message_id}}) do
    with message_info <- MessagesGateway.RedisManager.get(message_id)
      do
      render(conn, "message_status.json", message_id: message_id, message_status: message_info.sending_status)
    end
  end

# ---- Change message status ---------------------------------------------------------

  @spec change_message_status(conn, change_message_status_params) :: result when
          conn:   conn(),
          change_message_status_params: change_status_request(),
          result: result()

  def change_message_status(conn, %{"resource" => %{"message_id" => message_id, "sending_active" => active}}) do
    with {:ok, json_body} <- Jason.encode(%{sending_status: active}),
          :ok <- MessagesGateway.RedisManager.set(message_id, json_body)
      do
      render(conn, "message_change_status.json", %{sending_status: active})
    end

  end

# ---- Help functions ---------------------------------------------------------
  @spec add_to_db_and_queue(resource, priority_list) :: result when
          resource: message_request_body(),
          priority_list: MessagesGatewayInit.priority_list() | {:error, any()},
          result: {:ok, String.t()}
  def add_to_db_and_queue( _, {:error, _} = res), do: res
  def add_to_db_and_queue( %{"contact" => phone, "body" => body} = resource, priority_list) do
    with {:ok, message_id} <- UUID.generate_uuid(),
         :ok <- add_to_redis(message_id,  %{message_id: message_id, contact: phone, body: body,
           callback_url: Map.get(resource, "callback_url", ""), priority_list: priority_list,
           active: @sending_start_status, sending_status: @status_not_send}),
         :ok <- add_to_message_queue(%{message_id: message_id})
      do
        {:ok, message_id}
    end
  end

  @spec add_email_to_db_and_queue(contact, body, subject, priority_list) :: result when
          contact: String.t(),
          body: String.t(),
          subject: String.t(),
          priority_list: Prioritization.priority_list(),
          result: {:ok, String.t()}

  def add_email_to_db_and_queue(contact, body, subject, priority_list) do
    with {:ok, message_id} <- UUID.generate_uuid(),
         :ok <- add_to_redis(message_id, %{message_id: message_id, contact: contact, body: body, callback_url: "",
           priority_list: priority_list, subject: subject, active: @sending_start_status,
           sending_status: @status_not_send}),
         :ok <- add_to_message_queue(%{message_id: message_id})
      do
        {:ok, message_id}
    end
  end

  @spec add_to_redis(message_id, body) :: result when
          message_id: String.t(),
          body: map(),
          result: :ok | :error

  def add_to_redis(message_id, body) do
    case MessagesGateway.RedisManager.set(message_id, body) do
      :ok ->
        GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{:message_id => "message_id", status: "add_to_redis"}})
      {:error, error} ->
        GenServer.cast(MgLogger.Server, {:log, __MODULE__, error})
    end
    :ok
  end

  @spec add_to_message_queue(body) :: result when
          body: map(),
          result: term()

  def add_to_message_queue(body) do
    body_json = Jason.encode!(body)
    MessagesGateway.MqManager.publish(body_json)
  end

end