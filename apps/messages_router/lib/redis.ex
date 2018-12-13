defmodule Redis do
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

  @spec command(list) :: {:ok, term} | {:error, term}
  defp command(command) when is_list(command) do
    pool_size = Application.get_env(:messages_gateway,  MessagesGateway.Redis)
    connection_index = rem(System.unique_integer([:positive]), pool_size)

    Redix.command(:"redis_#{connection_index}", command)
  end

end
