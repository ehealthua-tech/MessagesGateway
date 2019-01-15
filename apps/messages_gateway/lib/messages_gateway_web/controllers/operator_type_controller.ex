defmodule MessagesGatewayWeb.OperatorTypeController do

  @moduledoc false
  use MessagesGatewayWeb, :controller
  alias DbAgent.OperatorTypesRequests
  alias DbAgent.OperatorsRequests

  action_fallback(MessagesGatewayWeb.FallbackController)

  @operator_active true
  @operator_inactive true

  def index(conn, _params) do
    with operator_types <- OperatorTypesRequests.list_operator_types()
      do
        render(conn, "index.json", %{operator_types: operator_types})
    end
  end

  def create(conn, %{"resource" => %{"operator_type_name" => operator_type_name, "priority" => priority}}) do
    with {:ok,_} <- OperatorTypesRequests.add_operator_type(%{name: operator_type_name, priority: priority, active: @operator_active})
      do
        render(conn, "create.json", %{status: "success"})
    end

  end

  def update_priority(conn, %{"resource" => operator_info}) do
    with {n, new_priority} <- OperatorTypesRequests.update_priority(operator_info)
      do
      MessagesGatewayInit.create_operators_list_to_redis()
      render(conn, "create.json", %{status: "success"})
    end
  end

  def select_operator_types__id([], acc), do: acc
  def select_operator_types__id([%{operator_types: operator_struct}| t], acc) do
    operator = Map.from_struct(operator_struct)
    select_operator_types__id(t, [%{operator.id => %{operator_configs: operator.config, priority_on_price: operator.priority}} | acc])
  end

  def deactivate(conn, %{"resource" => %{"operator_type_id" => operator_type_id, "active" => active}}) do
    with {1, _} <- OperatorTypesRequests.change_status(%{id: operator_type_id, active: active})
      do
        render(conn, "delete.json", %{status: "success"})
    end
  end

  def delete(conn, %{"id" => id}) do
    OperatorsRequests.operator_by_operator_type_id(id)
    |> delete_operator_type(id, conn)
  end

  defp delete_operator_type([], operator_type_id, conn) do
    with {_, nil} <- OperatorTypesRequests.delete(operator_type_id)
      do
        render(conn, "delete.json", %{status: "success"})
    end
  end

  defp delete_operator_type(_, _, _), do: {:error, :operators_present}


end
