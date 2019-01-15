defmodule MessagesGateway.OperatorsToCash do
  @moduledoc false
  
  use GenServer
  alias DbAgent.OperatorsRequests

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    state =
      OperatorsRequests.list_operators()
      |> select_operator([])
      |> add_operators_info_to_redis()
    {:ok, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def add_operators_info_to_redis(list_operators) do
    json = Jason.encode!(list_operators)
    Processes.spawn(MessagesGateway.RedisManager.set("operators_info", json))
    :ok
  end

  def select_operator([], acc), do: acc
  def select_operator([%{operator: operator_struct}| t], acc) do
    :io.format("~noperator_struct~p~n", [operator_struct])
    operator = Map.from_struct(operator_struct)
    :io.format("~noperator: ~p~n", [operator])
    x = %{id: operator.id, active: operator.active, name: operator.name,priority: operator.priority, limit: operator.limit}
    :io.format("~nx: ~p~n", [x])
    select_operator(t, [Map.merge(%{id: operator.id, active: operator.active, name: operator.name,
      priority: operator.priority, limit: operator.limit}, operator.config)| acc])
  end
end