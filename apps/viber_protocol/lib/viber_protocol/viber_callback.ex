defmodule ViberCallback do
  @moduledoc false

  use Plug.Router
  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "pong!")
  end

  # Handle incoming events, if the payload is the right shape, process the
  # events, otherwise return an error.
  post "/viber" do
    ViberProtocol.callback_response(conn)
    response(conn)
  end

#  defp response({:reply, data}, conn) when is_map(data) do
#    conn
#    |> put_resp_header("content-type", "application/json")
#    |> send_resp(200, Poison.encode!(data))
#  end
  defp response(conn) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, "")
  end
  # A catchall route, 'match' will match no matter the request method,
  # so a response is always returned, even if there is no route to match.
  match _ do
    send_resp(conn, 404, "oops... Nothing here :(")
  end
end
