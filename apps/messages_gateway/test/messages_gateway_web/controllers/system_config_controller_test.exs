defmodule MessagesGatewayWeb.SystemConfigControllerTest do
  use MessagesGatewayWeb.ConnCase
  use DbAgent.DataCase

  test "system config", %{conn: conn} do
    MessagesGateway.RedisManager.set("system_config", %{})
    result_changing_sys_config =
      select_sys_config(conn)
      |> Map.put("test", "test")
      |> add_sys_config(conn)
    assert result_changing_sys_config == "success"

  end

  defp select_sys_config(conn) do
    get(conn, "/api/system_config")
    |> json_response(200)
    |> get_in(["data"])
  end

    defp add_sys_config(sys_config, conn) do
    post(conn, "/api/system_config", %{"resource" => sys_config})
    |> json_response(200)
    |> get_in(["data", "status"])
  end
end