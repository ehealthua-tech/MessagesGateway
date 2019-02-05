defmodule ViberPlug do
  @moduledoc false
  @behaviour Plug
  import Plug.Conn

  def init(options), do: options

  def call(%{request_path: path} = conn, %{path: endpoint})
      when path != endpoint and endpoint != nil do
    send_resp(conn, 500, "")
  end

  def call(conn, opts) do
    conn
    |> fetch_query_params()
    |> get_params()
    |> handle(Keyword.get(opts, :handler))
    |> response(conn)
  end

  defp get_params(%{params: params} = conn) when is_map(params) do
    case  map_size(params) > 0 do
     true ->  params
     _->
       {:ok, body, _conn} = read_body(conn)
       Poison.decode!(body)
    end
  end

  defp handle(params, handler) when handler != nil, do: handler.(params)
  defp handle(_, _), do: :noreply

  defp response({:reply, data}, conn) when is_map(data) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, Poison.encode!(data))
  end
  defp response(:noreply, conn) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, "")
  end
end
