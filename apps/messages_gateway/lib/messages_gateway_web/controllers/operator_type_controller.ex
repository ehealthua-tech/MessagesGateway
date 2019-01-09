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

  def create(conn, %{"resource" => %{"operator_type_name" => operator_type_name}}) do
    with {:ok,_} <- OperatorTypesRequests.add_operator_type(%{name: operator_type_name, active: @operator_active})
      do
        render(conn, "create.json", %{status: "success"})
    end

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
    with {:ok, _} <- OperatorTypesRequests.delete(operator_type_id)
      do
        render(conn, "delete.json", %{status: "success"})
    end
  end

end
