defmodule MessagesGateway.RedisManager do
  @moduledoc false

  @spec get(binary) :: {:ok, term} | {:error, binary}
  def get(key) when is_binary(key) do
    with {:ok, value} <- command(["GET", key]) do
      if value == nil do
        {:error, :not_found}
      else
        {:ok, value}
      end
    else
      {:error, reason} = err ->
        Log.error("[#{__MODULE__}] Fail to get value by key (#{key}) with error #{inspect(reason)}")
        err
    end
  end

  @spec set(binary, term) :: :ok | {:error, binary}
  def set(key, value) when is_binary(key) and value != nil, do: do_set(["SET", key, value])

  @spec do_set(list) :: :ok | {:error, binary}
  defp do_set(params) do
    case command(params) do
      {:ok, _} ->
        :ok

      {:error, reason} = err ->
        Log.error("[#{__MODULE__}] Fail to set with params #{inspect(params)} with error #{inspect(reason)}")
        err
    end
  end

  @spec del(binary) :: {:ok, non_neg_integer} | {:error, binary}
  def del(key) when is_binary(key) do
    case command(["DEL", key]) do
      {:ok, n} when n >= 1 -> {:ok, n}
      err -> err
    end
  end

  def keys(key) when is_binary(key) do
    case command(["KEYS", key]) do
      {"ok", values} ->
        {:ok, values}
      error ->
        error
    end
  end

  @spec command(list) :: {:ok, term} | {:error, term}
  defp command(command) when is_list(command) do
    pool_size = Application.get_env(:messages_gateway,  MessagesGateway.RedisManager)[:pool_size]
    connection_index = rem(System.unique_integer([:positive]), pool_size)

    Redix.command(:"redis_#{connection_index}", command)
  end

end