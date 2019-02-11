defmodule MessagesGatewayWeb.OperatorsControllerTest do
  use MessagesGatewayWeb.ConnCase

  @test_type "test_sms_type"


  test " check operators functionality", %{conn: conn} do
      assert create_operator_type(@test_type, conn) == "success"
      [operator_type_info] = select_all_operator_type(conn)
      MessagesGateway.RedisManager.set("sms_protocol", %{})

      create_operator(operator_type_info, conn)
      [operator_info] = select_all_operator(conn)
      delete_operator(operator_info, conn)

      assert select_all_operator(conn) == []

      delete_operator_type(operator_type_info, conn)

      assert  select_all_operator_type(conn) == []
  end

  defp create_operator(operator_type_info, conn) do

    post(conn, "/api/operators" ,
    %{"resource" => %{
      "name" => "sms4",
      "operator_type_id" => get_in(operator_type_info, ["id"]),
      "protocol_name" => "sms_protocol",
      "config" => %{},
      "price" => 18,
      "limit" => 1000,
      "active" => false
    }})
    |> json_response(200)
    |> get_in(["data", "status"])
  end

  defp create_operator_type(name, conn) do
    post(conn, "/api/operator_type" , %{"resource" => %{"operator_type_name" => name}})
    |> json_response(200)
    |> get_in(["data", "status"])
  end

  defp select_all_operator_type(conn) do
    get(conn, "/api/operator_type")
    |> json_response(200)
    |> get_in(["data"])
  end

  defp select_all_operator(conn) do
    get(conn, "/api/operators")
    |> json_response(200)
    |> get_in(["data"])
  end

  defp delete_operator(operator_info, conn) do
    url_info = "/api/operators/" <> get_in(operator_info, ["id"])
    x = delete(conn, url_info)
    :io.format("~nx: ~p~n", [x])
  end

  defp delete_operator_type(operator_type_info, conn) do
    url_info = "/api/operator_type/" <> get_in(operator_type_info, ["id"])
    delete(conn, url_info)
  end


end