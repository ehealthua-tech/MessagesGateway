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
    with {:ok, _} <- status do
      render(conn, "create.json", %{status: "success"})
    end
  end

  def change_info(conn, %{"resource" => %{"id" => id, "config" => config} = operator_info}) do
    {_, operator_info_r} = Map.split(operator_info, ["id", "operator_type", "config"])
    with {1, _} <- OperatorsRequests.change_operator(id, [{:config, config} | convert(operator_info_r)])
      do
        render(conn, "create.json", %{status: "success"})
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _} <- OperatorsRequests.delete(id)
      do
        render(conn, "delete.json", %{status: "success"})
    end
  end

  defp convert(map) when is_map(map), do: Enum.map(map, fn {k,v} ->{String.to_atom(k),convert(v)}  end)
  defp convert(v), do: v

  def update_priority(conn, %{"resource" => operator_info}) do
    with {n, _} <- OperatorsRequests.update_priority(operator_info)
      do
      render(conn, "create.json", %{status: "success"})
    end
  end

end
