defmodule MessagesGatewayWeb.OperatorsController do
  @moduledoc false

  use MessagesGatewayWeb, :controller
  alias DbAgent.OperatorsRequests


  action_fallback(MessagesGatewayWeb.FallbackController)

  @operator_active true
  @operator_inactive false
  def index(conn, _params) do
    with operators <- OperatorsRequests.list_operators()
      do
      render(conn, "index.json", %{operators: operators})
    end
  end

  def create(conn, %{"resource" => operator_info}) do
    status = OperatorsRequests.add_operator(operator_info)
    with {:ok,op} <- status       do
      render(conn, "create.json", %{status: "success"})
    end
  end

  def change_info(conn, %{"resource" => operator_info}) do
    status = OperatorsRequests.change_operator(operator_info)
    with {:ok,op} <- status       do
      render(conn, "create.json", %{status: "success"})
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _} <- OperatorsRequests.delete(id)
      do
      render(conn, "delete.json", %{status: "success"})
    end
  end

end
