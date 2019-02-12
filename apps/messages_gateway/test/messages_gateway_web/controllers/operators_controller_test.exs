defmodule MessagesGatewayWeb.OperatorsControllerTest do
  use MessagesGatewayWeb.ConnCase

  @test_type "test_sms_type"


  test "check operators functionality", %{conn: conn} do
      assert create_operator_type(@test_type, conn) == "success"
      operator_type_info =
        select_all_operator_type(conn)
        |> Enum.find(fn(x) -> get_in(x, ["name"]) == @test_type end)
      assert operator_type_info != nil

      MessagesGateway.RedisManager.set("test", %{})

      create_operator(operator_type_info, "test", conn)
      operator_info =
        select_all_operator(conn)
        |> Enum.find(fn(x) -> get_in(x, ["name"]) == "test" end)
      assert operator_info != nil

      delete_operator(operator_info, conn)
      is_delete_operator =
        select_all_operator(conn)
        |> Enum.find(fn(x) -> get_in(x, ["name"]) == @test_type end)
      assert is_delete_operator == nil

      delete_operator_type(operator_type_info, conn)
      is_delete_type =
        select_all_operator_type(conn)
        |> Enum.find(fn(x) -> get_in(x, ["name"]) == @test_type end)
      assert  is_delete_type == nil
  end

  test "operators change info", %{conn: conn} do
    assert create_operator_type("test_for_change_type", conn) == "success"
    operator_type_info =
      select_all_operator_type(conn)
      |> Enum.find(fn(x) -> get_in(x, ["name"]) == "test_for_change_type" end)
    assert operator_type_info != nil

    MessagesGateway.RedisManager.set("test_for_change", %{})

    create_operator(operator_type_info, "test_for_change", conn)
    operator_info =
      select_all_operator(conn)
      |> Enum.find(fn(x) -> get_in(x, ["name"]) == "test_for_change" end)
    assert operator_info != nil
    change_operator(operator_info, conn)





    delete_operator(operator_info, conn)

    assert select_all_operator(conn) == []

    delete_operator_type(operator_type_info, conn)

    assert  select_all_operator_type(conn) == []
  end

  defp create_operator(operator_type_info, operator_name, conn) do

    post(conn, "/api/operators" ,
    %{"resource" => %{
      "name" =>operator_name,
      "operator_type_id" => get_in(operator_type_info, ["id"]),
      "protocol_name" => operator_name,
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

  defp change_operator(operator_info, conn) do
    operator_info_ch = Map.put(operator_info, "limit", 20)
    post(conn, "/api/operators/change" , %{"resource" => operator_info_ch})
    |> json_response(200)
    |> get_in(["data", "status"])
  end

  defp delete_operator(operator_info, conn) do
    url_info = "/api/operators/" <> get_in(operator_info, ["id"])
    delete(conn, url_info)
  end

  defp delete_operator_type(operator_type_info, conn) do
    url_info = "/api/operator_type/" <> get_in(operator_type_info, ["id"])
    delete(conn, url_info)
  end


end