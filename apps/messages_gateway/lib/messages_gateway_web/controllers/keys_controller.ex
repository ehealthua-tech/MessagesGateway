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
    with {:ok, user, key} <- generate()
      do
      render(conn, "index.json",  %{:user => user, :key => key, :status => :active})
    end
  end

  @spec deactivate(conn, params) :: result when
          conn:   conn(),
          params: %{"resource": %{"user": String.t()}},
          result: result()

  def deactivate(conn,%{"resource" => %{"user" => user}}) do
    with :ok <- deactivate(user)
      do
      render(conn, "change_keys.json", %{status: "success"})
    end
  end

  @spec activate(conn, params) :: result when
          conn:   conn(),
          params: %{"resource": %{"user": String.t()}},
          result: result()

  def activate(conn,%{"resource" => %{"user" => user}}) do
    with :ok <- activate(user)
      do
      render(conn, "change_keys.json", %{status: "success"})
    end
  end

  @spec delete(conn, params) :: result when
          conn:   conn(),
          params: %{"resource": %{"user": String.t()}},
          result: result() | {:error, :operators_present}

  def delete(conn, %{"id" => id}) do
    with :ok <- delete(id)
      do
      render(conn, "change_keys.json", %{status: "success"})
    end
  end

  @spec generate() :: {:ok, user: String.t(), key: String.t()}

  defp generate() do
    key_binary = <<
      System.system_time(:nanosecond)::64,
      :erlang.phash2({node(), self()}, 16_777_216)::24,
      :erlang.unique_integer()::32
    >>
    key = Base.hex_encode32(key_binary, case: :lower)
    user_binary = <<
      System.system_time(:nanosecond)::32,
      :erlang.phash2({node(), self()}, 16_777_216)::24,
      :erlang.unique_integer()::16
    >>
    user = Base.hex_encode32(user_binary, case: :lower)
    {:ok, ref} = :dets.open_file(:mydata_file, [])
    :dets.insert(ref, {user, {key, :active}})
    :dets.close(ref)
    {:ok, user, key}
  end

  @spec deactivate(user: String.t()) :: :ok

  defp deactivate(user) do
    {:ok, ref} = :dets.open_file(:mydata_file, [])
    [{user, {key,active}}] = :dets.lookup(ref, user)
    if active == :not_active do
      :ok
    else
      :dets.insert(ref, {user, {key, :not_active}})
    end
    :dets.close(ref)
  end

  @spec activate(user: String.t()) :: :ok

  defp activate(user) do
    {:ok, ref} = :dets.open_file(:mydata_file, [])
    [{user, {key,active}}] = :dets.lookup(ref, user)
    if active == :active do
      :ok
    else
      :dets.insert(ref, {user, {key, :active}})
    end
    :dets.close(ref)
  end

  @spec delete(user: String.t()) :: :ok

  defp delete(user) do
    {:ok, ref} = :dets.open_file(:mydata_file, [])
    if [] == :dets.lookup(ref, user) do
      :ok
    else
      :dets.delete(ref, user)
    end
    :dets.close(ref)
  end

end
