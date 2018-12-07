defmodule MessagesGatewayWeb.AdminController do
  use MessagesGatewayWeb, :controller

  action_fallback(MessagesGatewayWeb.FallbackController)

  @messages_gateway_conf :messages_gateway_conf
  @operators_config :operators_config

#  ---- send a message to the client any available way ------------------------

  def get_system_config(conn, _params) do
    with {:ok, system_config} <- RedisManager.get(@messages_gateway_conf)
      do
      render(conn, "system_config.json",  %{:config => system_config})
    end

  end

#  ---- send a message to the client any available way ------------------------

  def add_system_config(conn, %{"resource" => %{"auth" => auth, "password" => password}}) do
    with :ok <- RedisManager.set(@messages_gateway_conf)
      do
       render(conn, "change_system_config.json", %{status: :ok})
    end
  end

  def add_system_config(conn,  _) do
    render(conn, "index.json", %{status: :ok})
  end

#  ---- send a message to the client any available way ------------------------

  def edit_system_config(conn, %{"resource" => %{"auth" => auth, "password" => password}}) do
    with {:ok, system_config} <- RedisManager.set(@messages_gateway_conf)
      do
      render(conn, "change_system_config.json", %{status: :ok})
    end

  end

  def edit_system_config(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end
#################################### END ######################################

#  ---- send a message to the client any available way ------------------------

  def get_operator_types(conn, _params) do
    with {:ok, operator_types} <- ABAgent.OperatorTypes.select_all_operator_types()
      do
      render(conn, "operator_types.json", %{operator_types: operator_types})
    end
  end

  def add_operator_type(conn, %{"resource" => %{"operator_type_name" => operator_type_name}}) do
    with :ok <- ABAgent.OperatorTypes.insert_operator_types(operator_type_name)
      do
      render(conn, "change_operator_type.json", %{status: :ok})
    end

  end

  def add_operator_type(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end

#  ---- send a message to the client any available way ------------------------

  def delete_operator_type(conn, %{"resource" => %{"operator_type_id" => operator_type_id}}) do
    with :ok <- ABAgent.OperatorTypes.deactivate(operator_type_id)
      do
      render(conn, "change_operator_type.json", %{status: :ok})
    end

  end

  def delete_operator_type(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end

#################################### END ######################################

#  ---- send a message to the client any available way ------------------------

  def get_all_operators(conn, _params) do
    with {:ok, operators} <- ABAgent.Operators.select_all_operators()
      do
      render(conn, "operators.json", %{operators: operators})
    end
  end

#  ---- send a message to the client any available way ------------------------

  def add_operator(conn, %{"resource" => %{"operator_name" => operator_name, "limit_per_sec" => limit,
    "message_price" => price, "operator_config" => config} = operator_info}) do
    with :ok <- ABAgent.Operators.insert_operator(operator_info)
      do
      render(conn, "change_operator.json", %{status: :ok})
    end
  end

  def add_operator(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end

#  ---- send a message to the client any available way ------------------------

  def operator_edit(conn, %{"resource" => %{"operator_id" => operator_id, "operator_name" => name,
    "limit_per_sec" => limit, "message_price" => price, "operator_config" => config,
    "operator_active" => operator_active} = operator_info}) do

    with :ok <- ABAgent.Operators.update_operator(operator_info)
      do
      render(conn, "change_operator.json", %{status: :ok})
    end

  end

  def operator_edit(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end

#  ---- send a message to the client any available way ------------------------

  def operator_delete(conn, %{"resource" => %{"operator_id" => operator_id}}) do
    with :ok <- ABAgent.Operators.deactivate_operator(operator_id)
      do
      render(conn, "change_operator.json", %{status: :ok})
    end
  end

  def operator_delete(conn,  _) do
    render(conn, "index.json", %{:body => %{:status => "error", :message => "Missed some request params"}})
  end

end

