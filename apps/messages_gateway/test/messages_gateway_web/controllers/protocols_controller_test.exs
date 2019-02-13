defmodule MessagesGatewayWeb.ProtocolsControllerTest do
  use MessagesGatewayWeb.ConnCase

  @protocols_name ["sms_protocol", "ip_protocol", "mmmmess_protocol", "mail_protocol"]

  test "select_all_protocols", %{conn: conn} do
    :ok = set_protocols(@protocols_name)
    res =
      select_all_protocols(conn)
      |> Enum.member?("mmmmess_protocol")
    assert res == true
  end

  test "select_protocol_config", %{conn: conn} do
    :ok = set_protocols(@protocols_name)
    res = select_protocol_on_id("sms_protocol", conn)
    assert res != {:error, :not_found}
  end

  defp set_protocols([]), do: :ok
  defp set_protocols([protocol_name | t]) do
    MessagesGateway.RedisManager.set(protocol_name, %{})
    set_protocols(t)
  end

  defp select_all_protocols(conn) do
    get(conn, "/api/get_protocol")
    |> json_response(200)
    |> get_in(["data", "protocols"])
  end

  defp select_protocol_on_id(protocol_name, conn) do
    get(conn, "/api/get_protocol/" <> protocol_name)
    |> json_response(200)
    |> get_in(["data", "status"])
  end

end