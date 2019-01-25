defmodule MessagesGatewayWeb.OperatorTypeController do

  @moduledoc false
  use MessagesGatewayWeb, :controller
  alias DbAgent.OperatorTypesRequests
  alias DbAgent.OperatorsRequests
  alias MessagesGateway.RedisManager
  action_fallback(MessagesGatewayWeb.FallbackController)

  @operator_active true
  @operator_inactive true

  @typep conn()           :: Plug.Conn.t()
  @typep result()         :: Plug.Conn.t()

  @spec index(conn, params) :: result when
          conn:   conn(),
          params: map(),
          result: result()

  def index(conn, _params) do
    with operator_types <- OperatorTypesRequests.list_operator_types()
      do
        render(conn, "index.json", %{operator_types: operator_types})
    end
  end

  @spec create(conn, create_params) :: result when
          conn:   conn(),
          create_params: %{"resource": %{"operator_type_name": String.t(), "priority": integer()}},
          result: result()

  def create(conn, %{"resource" => %{"operator_type_name" => operator_type_name, "priority" => priority}}) do
    with {:ok,_} <- OperatorTypesRequests.add_operator_type(%{name: operator_type_name, priority: priority, active: @operator_active})
      do
        render(conn, "create.json", %{status: "success"})
    end
  end

  @spec update_priority(conn, params) :: result when
          conn:   conn(),
          params: %{"resource": %{"id": String.t(),
                                  "name": String.t(),
                                  "priority": integer(),
                                  "active": boolean()}},
          result: result()

  def update_priority(conn, %{"resource" => operator_info}) do
    with {n, new_priority} <- OperatorTypesRequests.update_priority(operator_info)
      do
      RedisManager.set("operators_config",  MessagesGatewayInit.create_operators_list_to_redis())
      render(conn, "create.json", %{status: "success"})
    end
  end

  @spec deactivate(conn, deactivate_params) :: result when
          conn:   conn(),
          deactivate_params: %{"resource": %{"operator_type_id": String.t(), "active": boolean()}},
          result: result()

  def deactivate(conn, %{"resource" => %{"operator_type_id" => operator_type_id, "active" => active}}) do
    with {1, _} <- OperatorTypesRequests.change_status(%{id: operator_type_id, active: active})
      do
        render(conn, "delete.json", %{status: "success"})
    end
  end

  @spec delete(conn, delete_params) :: result when
          conn:   conn(),
          delete_params: %{"id": String.t()},
          result: result() | {:error, :operators_present}

  def delete(conn, %{"id" => id}) do
    OperatorsRequests.operator_by_operator_type_id(id)
    |> delete_operator_type(id, conn)
  end

  @spec delete_operator_type(operators, id, conn) :: result when
          operators: [],
          id: String.t(),
          conn: conn(),
          result: result() | {:error, :operators_present}

  defp delete_operator_type([], operator_type_id, conn) do
    with {_, nil} <- OperatorTypesRequests.delete(operator_type_id)
      do
        render(conn, "delete.json", %{status: "success"})
    end
  end

  defp delete_operator_type(_, _, _), do: {:error, :operators_present}


end
