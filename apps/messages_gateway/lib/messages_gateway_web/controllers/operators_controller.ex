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

  def show(conn, %{"id" => id}) do
    with result <- OperatorsRequests.operator_by_id(id)
      do
      render(conn, "show.json", %{operator: result})
    end
  end

  defp convert(map) when is_map(map), do: Enum.map(map, fn {k,v} ->{String.to_atom(k),convert(v)}  end)
  defp convert(v), do: v

  def update_priority(conn, %{"resource" => operator_info}) do
    with {n, new_priority} <- OperatorsRequests.update_priority(operator_info),
          operators <- OperatorsRequests.list_operators(),
          priority <- select_operators_id(operators, []),
          {:ok, json} <- Jason.encode(priority),
          :ok <- MessagesGateway.RedisManager.set("operators_config", json)
      do
        :io.format("~nnew_priority: ~p~n~n", [priority])
      render(conn, "create.json", %{status: "success"})
    end
  end

  def select_operators_id([], acc), do: acc
  def select_operators_id([%{operator: operator_struct}| t], acc) do
    operator = Map.from_struct(operator_struct)
    select_operators_id(t, [%{operator.id => %{operator_configs: operator.config, priority_on_price: operator.priority}} | acc])
  end

end
