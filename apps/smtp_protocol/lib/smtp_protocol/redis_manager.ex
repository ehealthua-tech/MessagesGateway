defmodule SmtpProtocol.RedisManager do
  @moduledoc false

  @spec get(binary) :: map()| {:error, binary}
  def get(key) when is_binary(key), do: command(["GET", key]) |> check_get(key)

  defp check_get({:ok, value}, _) when value == nil, do:  {:error, :not_found}
  defp check_get({:ok, value}, _), do: Jason.decode!(value, [keys: :atoms])
  defp check_get({:error, reason} = err, key) do
    err
  end

  @spec set(binary, term) :: :ok | {:error, binary}
  def set(key, value) when is_binary(key) and value != nil, do: do_set(["SET", key, Jason.encode!(value)])

  @spec do_set(list) :: :ok | {:error, binary}
  defp do_set(params), do: command(params) |> check_set(params)

  defp check_set({:ok, _}, _), do: :ok
  defp check_set({:error, reason} = err, params) do
    err
  end

  @spec del(binary) :: {:ok, non_neg_integer} | {:error, binary}
  def del(key) when is_binary(key), do:  command(["DEL", key]) |> check_del()

  defp check_del({:ok, n}) when n >= 1, do: {:ok, n}
  defp check_del(err), do: err

  @spec command(list) :: {:ok, term} | {:error, term}
  def command(command) when is_list(command) do
    pool_size = Application.get_env(:viber_protocol, ViberProtocol.RedisManager)[:pool_size]
    connection_index = rem(System.unique_integer([:positive]), pool_size)
    {:ok, app_name} = :application.get_application(__MODULE__)
    Redix.command(:"redis_#{Atom.to_string(app_name)}_#{connection_index}", command)
  end

end