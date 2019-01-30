defmodule MessagesGateway.Plugs.Headers do
  @moduledoc """
  Plug.Conn helpers
  """

  @header_consumer_id "x-consumer-id"
  @header_api_key "api-key"

  import Plug.Conn, only: [put_status: 2, get_req_header: 2, halt: 1]
  import Phoenix.Controller, only: [render: 4]

  @spec required_headers(Plug.Conn.t(), map()) :: Plug.Conn.t() | :error

  def required_headers(%Plug.Conn{params: params, req_headers: headers} = conn, _) do
    authorization = get_header(headers, "Authorization")
    ["Bearer", user_and_key ] =  String.split(authorization, " ")
    [user, key_hash] = String.split(user_and_key, ":")
    {:ok, ref} = :dets.open_file(:mydata_file, [])
    [{user, {key, active}}] = :dets.lookup(ref, user)
    if Base.hex_encode32(:crypto.hash(:sha256,key), case: :lower) == key_hash do
      conn
    else
      :error
    end
    conn
  end

  def get_header(headers, header) when is_list(headers) do
    Enum.reduce_while(headers, nil, fn {k, v}, acc ->
      if String.downcase(k) == String.downcase(header) do
        {:halt, v}
      else
        {:cont, acc}
      end
    end)
  end

end
