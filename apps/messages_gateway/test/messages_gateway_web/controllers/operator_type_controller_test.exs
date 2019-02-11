defmodule MessagesGatewayWeb.OperatorTypeControllerTest do
  use MessagesGatewayWeb.ConnCase

  @test "tests_operator_type"

  test "create_new_operator_type", %{conn: conn} do
    result = create_operator_type(@test, conn)
    assert result == "success"
  end

  test "select_all_operators_type", %{conn: conn} do
    result = select_all_operator_type(conn)
    assert result > 0
    assert Enum.find(result, fn(x) -> get_in(x, ["name"]) == @test end) != nil
  end

  test "update_priority_of_operator_type", %{conn: conn} do
    result = select_all_operator_type(conn)
    assert result > 0
    operator_info = Enum.find(result, fn(x) -> get_in(x, ["name"]) == @test end) != nil
    assert operator_info != nil

  end

  test "deactivate_operator_type", %{conn: conn} do
#    res = create_operator_type("tests_operator", conn)
#    assert result == "success"
  end

  test "delete_operator_type", %{conn: conn} do
#    res = create_operator_type("tests_operator", conn)
#    assert result == "success"
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

  defp update_priority_of_operator_type(update_params, conn) do
    post(conn, "/api/operator_type" , %{"resource" => %{"operator_type_name" => name}})
  end

  defp deactivate_operator_type(operator_type_info, conn) do

  end

  defp delete_operator(operator_type_id, conn) do

  end
end