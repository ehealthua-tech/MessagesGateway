defmodule MessagesGatewayWeb.AdminController do
  use MessagesGatewayWeb, :controller

  def get_system_config(conn, _params) do
    case {:ok, %{:auth => "user", :password => "12345"}} do # mockup
   # case DbAgent.get_system_config() do
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

  def add_system_config(conn, %{"resource" => body}) do
    case :ok do # mockup
      # case DbAgent.add_system_config(body) do
      :ok ->
        render(conn, "index.json",
          %{:body => %{
            :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
            :data => %{:status => "ok"}}}
        )
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def edit_system_config(conn, %{"resource" => body}) do
    case :ok do # mockup
      # case DbAgent.edit_system_config(body) do
      :ok ->
        render(conn, "index.json",
          %{:body => %{
            :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
            :data => %{:status => "ok"}}}
        )
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def get_operator_types(conn, _params) do
    case {:ok, [%{:operator_type_id => 1, :operator_type_name => "SMS"}, %{:operator_type_id => 2, :operator_type_name => "Email"}, %{:operator_type_id => 3, :operator_type_name => "Messenger"}]} do # mockup
      # case DbAgent.get_operator_types() do
      {:ok, response} ->
        render(conn, "index.json",
          %{:body => %{
            :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
            :data => response}})
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def add_operator_type(conn, %{"resource" => body}) do
    case :ok do # mockup
      # case DbAgent.add_operator_type(body) do
      :ok ->
        render(conn, "index.json",
          %{:body => %{
            :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
            :data => %{:status => "ok"}}}
        )
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def delete_operator_type(conn, %{"resource" => body}) do
    case :ok do # mockup
      # case DbAgent.delete_operator_type(body) do
      :ok ->
        render(conn, "index.json",
          %{:body => %{
            :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
            :data => %{:status => "ok"}}}
        )
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def get_all_operators(conn, _params) do
    case {:ok, [%{:id => 1, :name => "LifeCell", :limit => 1000, :price => 12, :config => %{:api => "lifecell.com"}},
                %{:id => 2, :name => "Vodafone", :limit => 2000, :price => 13, :config => %{:api => "vodafone.com"}}]} do # mockup
      # case DbAgent.get_all_operators() do
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

  def add_operator(conn, %{"resource" => body}) do
    case :ok do # mockup
      # case DbAgent.add_operator(body) do
      :ok ->
        render(conn, "index.json",
          %{:body => %{
            :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
            :data => %{:status => "ok"}}}
        )
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def operator_edit(conn, %{"resource" => body}) do
    case :ok do # mockup
      # case DbAgent.operator_edit(body) do
      :ok ->
        render(conn, "index.json",
          %{:body => %{
            :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
            :data => %{:status => "ok"}}}
        )
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def operator_delete(conn, %{"resource" => body}) do
    case :ok do # mockup
      # case DbAgent.operator_delete(body) do
      :ok ->
        render(conn, "index.json",
          %{:body => %{
            :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
            :data => %{:status => "ok"}}}
        )
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def send_message(conn, %{"resource" => body}) do
    case :ok do # mockup
      # case MessagesRouter.send_message(body) do
      :ok ->
    render(conn, "index.json",
      %{:body => %{
        :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
        :data => %{:status => "ok"}}}
    )
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def send_sms(conn, %{"resource" => body}) do
    case :ok do # mockup
      # case MessagesRouter.send_sms(body) do
      :ok ->
    render(conn, "index.json",
      %{:body => %{
        :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
        :data => %{:status => "ok"}}}
    )
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def send_email(conn, %{"resource" => body}) do
    case :ok do # mockup
      # case MessagesRouter.send_email(body) do
      :ok ->
    render(conn, "index.json",
      %{:body => %{
        :meta => %{:url => "https://localhost:4000", :type => "list", :code => "200",:idempotency_key => "iXXekd88DKqo", :request_id => "qudk48fFlaP"},
        :data => %{:status => "ok"}}}
    )
      {:error, error} ->
        render(conn, "index.json", %{:body => %{:status => "error", :message => error}})
    end
  end

  def message_status(conn, %{"resource" => body}) do
    case {:ok, %{:status => "sending"}} do # mockup
      # case MessagesRouter.message_status() do
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
end
