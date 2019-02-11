defmodule MessagesGateway.Plugs.Headers do
  @moduledoc """
  Plug.Conn helpers
  """
  use MessagesGatewayWeb, :plugs

  @type dets_authorization_info() :: [{String.t, {String.t, boolean(), String.t, String.t}}]

  @authorization_header_key "authorization"

#  --Error messages--
  @inactive_user    "User is inactive or deleted"
  @incorrect_key    "Incorrect key for authorization"
  @missing_header   "Missing header authorization"
  @incorrect_params "Incorrect params for authorization"

  @spec required_headers(Plug.Conn.t(), any()) :: Plug.Conn.t() | no_return()
  def required_headers(conn, _) do
    get_req_header(conn,  @authorization_header_key)
    |> select_authorization_params(conn)
  end

  @spec select_authorization_params(list(), Plug.Conn.t()) :: Plug.Conn.t() | no_return()
  defp select_authorization_params([], conn), do: response_error(conn, @missing_header)
  defp select_authorization_params([authorization], conn), do: check_authorization_params(authorization, conn)
  defp select_authorization_params(_, conn), do: response_error(conn, @missing_header)

  @spec check_authorization_params(String.t(), Plug.Conn.t()) :: Plug.Conn.t() | no_return()
  defp check_authorization_params("Bearer" <> " " <> <<user::binary-size(16)>> <> ":" <> key_hash, conn) do
    file_name = Application.get_env(:messages_gateway, MessagesGatewayWeb.KeysController)[:dets_file_name]
    {:ok, ref} = :dets.open_file(file_name, [])
    :dets.lookup(ref, user)
    |> check_user_status(key_hash, conn)
  end
  defp check_authorization_params(_, conn), do: response_error(conn,  @incorrect_params)

  @spec check_user_status(dets_authorization_info(), String.t(), Plug.Conn.t()) :: Plug.Conn.t() | no_return()
  defp check_user_status([{user, {key, true, _, _}}], key_hash, conn) do
    Base.hex_encode32(:crypto.hash(:sha256, key), case: :lower)
    |> check_authorization_keys(key_hash, conn)
  end
  defp check_user_status(_, _, conn), do: response_error(conn, @inactive_user)

  @spec check_authorization_keys(String.t(), String.t(), Plug.Conn.t()) :: Plug.Conn.t() | no_return()
  defp check_authorization_keys(our_key, key_hash, conn) when our_key == key_hash, do: conn
  defp check_authorization_keys(our_key, key_hash, conn), do: response_error(conn,  @incorrect_key)

  @spec response_error(Plug.Conn.t(), String.t()) ::  no_return()
  defp response_error(conn, error_message) do
    conn
    |> put_status(:unauthorized)
    |> put_view(EView.Views.Error)
    |> render(:"401", %{
      message: error_message,
      invalid: [
        %{
          entry_type: :header,
          entry: "header_name"
        }
      ]
    })
    |> halt()
  end

end
