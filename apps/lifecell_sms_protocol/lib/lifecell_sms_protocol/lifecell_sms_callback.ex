defmodule LifecellSmsProtocol.LifecellSmsCallback do
  @moduledoc false
  @behaviour Plug
  import Plug.Conn
  import SweetXml

  @sms_status_request_parse_schema [status: ~x"//state/text()", lifecell_sms_id: ~x"./@id", date:  ~x"./@date"]

  def init(options), do: options

  def call(%{request_path: path} = conn, %{path: endpoint})
      when path != endpoint and endpoint != nil do
    send_resp(conn, 500, "")
  end

  def call(conn, opts) do
    try do
      resp_body =
        conn
        |> fetch_query_params()
        |> get_params()
        #@todo add select messages from redis
#      spawn(LifecellSmsProtocol, check_sending_status, resp_body)
      response(conn)
    catch
      _-> send_resp(conn, 500, "")
    end
  end

  defp get_params(%{params: params} = conn) when is_map(params) and map_size(params) > 0, do: {:ok, params}
  defp get_params(conn) do
    conn
    |> read_body
    |> decode_body
  end

  defp decode_body({:ok, response_body, _conn}), do: xmap(response_body, @sms_status_request_parse_schema)

  defp response(conn) do
    conn
    |> send_resp(200, "<status>accepted</status>")
  end
end