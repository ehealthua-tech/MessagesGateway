defmodule MessagesRouter.RedisManager do
  @moduledoc false

  @expire_time 60*60

  @spec get(binary) :: term | {:error, binary}
  def get(key) when is_binary(key), do: command(["GET", key]) |> check_get(key)

  @spec check_get({:ok, nil} | {:ok, map()} | {:error, term()}, term()) :: {:error, :not_found} | map()
  defp check_get({:ok, value}, _) when value != nil, do: Jason.decode!(value, [keys: :atoms])
  defp check_get(_, _key), do: {:error, :not_found}

  @spec set(binary, term) :: :ok | {:error, binary}
  def set(key, value) when is_binary(key) and value != nil, do: do_set(["SET", key, Jason.encode!(value)])

  @spec setex(binary, term) :: :ok | {:error, binary}
  def setex(key, value) when is_binary(key) and value != nil, do: do_set(["SETEX", key, @expire_time, Jason.encode!(value)])

  @spec do_set(list) :: :ok | {:error, binary}
  defp do_set(params), do: command(params) |> check_set(params)

  @spec check_set({:ok, term} | {:error, term}, term()) :: :ok | {:error, term()}
  defp check_set({:ok, _}, _), do: :ok
  defp check_set({:error, _}, _), do: :error

  @spec del(binary) :: {:ok, non_neg_integer} | {:error, binary}
  def del(key) when is_binary(key), do:  command(["DEL", key]) |> check_del()

  @spec check_del({:ok, term} | term()) :: {:ok, term()} | term()
  defp check_del({:ok, n}) when n >= 1, do: {:ok, n}
  defp check_del(err), do: err

  @spec command(list) :: {:ok, term} | {:error, term}
  def command(command) when is_list(command) do
    pool_size = String.to_integer(Application.get_env(:messages_router, MessagesRouter.RedisManager)[:pool_size])
    connection_index = rem(System.unique_integer([:positive]), pool_size)
    {:ok, app_name} = :application.get_application(__MODULE__)
    Redix.command(:"redis_#{Atom.to_string(app_name)}_#{connection_index}", command)
  end

end