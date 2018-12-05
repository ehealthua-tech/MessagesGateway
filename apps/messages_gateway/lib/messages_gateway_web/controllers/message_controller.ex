defmodule MessagesGatewayWeb.MessageController do
  use MessagesGatewayWeb, :controller

  def send_message(conn, %{"resource" => %{"request_id" => request_id, "contact" => contact, "body" => body} = resource}) do
    uuid = MessagesGateway.UUID.generate_uuid()
    priority_list = MessagesGateway.DbAgent.get_priority_list()
    body = Jason.encode!(Map.merge(resource, %{"uuid" => uuid, "priority_list" => priority_list}))
    case :ok do # mockup
      # case MessagesGateway.MqPublisher.publish(body) do
      :ok ->
        case :ok do # mockup
          # case MessagesGateway.RedisMannager.put(uuid, "true", "false") do  TODO RedisMannager
          :ok ->
            render(conn, "index.json",
              %{:body => %{
                :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
                :data => %{:status => "ok"}}}
            )
          :error ->
            render(conn, "index.json", %{:body => %{:status => "error", :message => "Redis error"}})
        end
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def send_message(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end

  def send_sms(conn, %{"resource" => %{"request_id" => request_id, "phone" => phone, "body" => body} = resource}) do
    uuid = MessagesGateway.UUID.generate_uuid()
    priority_list = [1] #only sms
    body = Jason.encode!(Map.merge(resource, %{"uuid" => uuid, "priority_list" => priority_list}))
    #  case :ok do # mockup
    case MessagesGateway.MqPublisher.publish(body) do
      :ok ->
        case :ok do # mockup
          # case MessagesGateway.RedisMannager.put(uuid, "true", "false") do  TODO RedisMannager
          :ok ->
            render(conn, "index.json",
              %{:body => %{
                :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
                :data => %{:status => "ok"}}}
            )
          :error ->
            render(conn, "index.json", %{:body => %{:status => "error", :message => "Redis error"}})
        end
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def send_sms(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end

  def send_email(conn, %{"resource" => %{"request_id" => request_id, "email" => email, "body" => body} = resource}) do
    uuid = MessagesGateway.UUID.generate_uuid()
    priority_list = [2] #only email
    body = Jason.encode!(Map.merge(resource, %{"uuid" => uuid, "priority_list" => priority_list}))
    case :ok do # mockup
      # case MessagesGateway.MqPublisher.publish(body) do
      :ok ->
        case :ok do # mockup
          # case MessagesGateway.RedisMannager.put(uuid, "true", "false") do  TODO RedisMannager
          :ok ->
            render(conn, "index.json",
              %{:body => %{
                :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
                :data => %{:status => "ok"}}}
            )
          :error ->
            render(conn, "index.json", %{:body => %{:status => "error", :message => "Redis error"}})
        end
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def send_email(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end

  def message_status(conn, %{"resource" => %{"request_id" => request_id}}) do
    case {:ok, %{:status => "sending"}} do # mockup
      # case MessagesRouter.message_status(request_id) do
      {:ok, response} ->
        render(conn, "index.json",
          %{:body => %{
            :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
            :data => response}}
        )
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def message_status(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end

end
