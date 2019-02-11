defmodule MessagesGatewayWeb.KeysController do
  @moduledoc false

  use MessagesGatewayWeb, :controller
  action_fallback(MessagesGatewayWeb.FallbackController)

  @typep conn()           :: Plug.Conn.t()
  @typep result()         :: Plug.Conn.t()

  @spec index(conn, params) :: result when
          conn:   conn(),
          params: map(),
          result: result()

  def index(conn, _params) do
    with :ok <- generate()
      do
      render(conn, "change_keys.json", %{status: "success"})
    end
  end

  @spec get_all(conn, params) :: result when
          conn:   conn(),
          params: map(),
          result: result()

  def get_all(conn, _params) do
    with {:ok, keys} <- all_keys()
      do
      render(conn, "keys.json", %{keys: keys})
    end
  end

  @spec deactivate(conn, params) :: result when
          conn:   conn(),
          params: %{"resource": %{"id": String.t()}},
          result: result()

  def deactivate(conn,%{"resource" => %{"id" => id}}) do
    with :ok <- deactivate(id)
      do
      render(conn, "change_keys.json", %{status: "success"})
    end
  end

  @spec activate(conn, params) :: result when
          conn:   conn(),
          params: %{"resource": %{"id": String.t()}},
          result: result()

  def activate(conn,%{"resource" => %{"id" => id}}) do
    with :ok <- activate(id)
      do
      render(conn, "change_keys.json", %{status: "success"})
    end
  end

  @spec delete(conn, params) :: result when
          conn:   conn(),
          params: %{"resource": %{"id": String.t()}},
          result: result() | {:error, :operators_present}

  def delete(conn, %{"id" => id}) do
    with :ok <- delete(id)
      do
      render(conn, "change_keys.json", %{status: "success"})
    end
  end

  @spec generate() :: :ok | {:error, any()}

  defp generate() do
    file_name = Application.get_env(:messages_gateway, MessagesGatewayWeb.KeysController)[:dets_file_name]
    key_binary = <<
      System.system_time(:nanosecond)::64,
      :erlang.phash2({node(), self()}, 16_777_216)::24,
      :erlang.unique_integer()::32
    >>
    key = Base.hex_encode32(key_binary, case: :lower)
    id_binary = <<
      System.system_time(:nanosecond)::32,
      :erlang.phash2({node(), self()}, 16_777_216)::24,
      :erlang.unique_integer()::16
    >>
    id = Base.hex_encode32(id_binary, case: :lower)
    {:ok, ref} = :dets.open_file(file_name, [])
    now = DateTime.to_string(DateTime.truncate(DateTime.utc_now(), :second))
    :dets.insert(ref, {id, {key, :true, now, now}})
    :dets.close(ref)
  end

  @spec all_keys() :: {:ok, list()}

  def all_keys do
    file_name = Application.get_env(:messages_gateway, MessagesGatewayWeb.KeysController)[:dets_file_name]
    {:ok, ref} = :dets.open_file(file_name, [])
    list = :dets.select(ref, [{:"$1", [], [:"$1"]}])
    map = Enum.map(list, fn({id, {key, status, created, updated}}) ->
      %{id: id, key: key, active: status, created: created, updated: updated} end)
    {:ok, map}
  end

  @spec deactivate(id: String.t()) :: :ok

  defp deactivate(id) do
    file_name = Application.get_env(:messages_gateway, MessagesGatewayWeb.KeysController)[:dets_file_name]
    {:ok, ref} = :dets.open_file(file_name, [])
    [{id, {key,status,created,_updated}}] = :dets.lookup(ref, id)
    if status == :false do
      :ok
    else
      :dets.insert(ref, {id, {key, :false, created, DateTime.to_string(DateTime.truncate(DateTime.utc_now(), :second))}})
    end
    :dets.close(ref)
  end

  @spec activate(id: String.t()) :: :ok

  defp activate(id) do
    file_name = Application.get_env(:messages_gateway, MessagesGatewayWeb.KeysController)[:dets_file_name]
    {:ok, ref} = :dets.open_file(file_name, [])
    [{id, {key,status,created,_updated}}] = :dets.lookup(ref, id)
    if status == :true do
      :ok
    else
      :dets.insert(ref, {id, {key, :true, created, DateTime.to_string(DateTime.truncate(DateTime.utc_now(), :second))}})
    end
    :dets.close(ref)
  end

  @spec delete(id: String.t()) :: :ok

  defp delete(id) do
    file_name = Application.get_env(:messages_gateway, MessagesGatewayWeb.KeysController)[:dets_file_name]
    {:ok, ref} = :dets.open_file(file_name, [])
    if [] == :dets.lookup(ref, id) do
      :ok
    else
      :dets.delete(ref, id)
    end
    :dets.close(ref)
  end

end
