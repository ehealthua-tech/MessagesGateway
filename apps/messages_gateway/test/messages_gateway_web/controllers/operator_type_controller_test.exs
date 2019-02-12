defmodule MessagesGatewayWeb.OperatorTypeControllerTest do
  use MessagesGatewayWeb.ConnCase

  @test "operator_type tests"

  test " check operator_type functionality", %{conn: conn} do
    result = create_operator_type(@test, conn)
    assert result == "success"

    result = select_all_operator_type(conn)
    assert result > 0

    operator_info = Enum.find(result, fn(x) -> get_in(x, ["name"]) == @test end)
    assert operator_info != nil

    update_priority_res = update_priority_of_operator_type(operator_info, conn)
    new_result = select_all_operator_type(conn)
    assert new_result > 0
    new_operator_info = Enum.find(new_result, fn(x) -> get_in(x, ["name"]) == @test end)
    assert get_in(new_operator_info, ["priority"]) == update_priority_res

    deactivate_operator_type(new_operator_info, conn)

    deactivate_result = select_all_operator_type(conn)
    assert deactivate_result > 0

    operator_info_deactivate = Enum.find(deactivate_result, fn(x) -> get_in(x, ["name"]) == @test end)
    assert get_in(operator_info_deactivate, ["active"]) != get_in(new_operator_info, ["active"])

    delete_operator(operator_info_deactivate, conn)

    is_delete_type =
      select_all_operator_type(conn)
      |> Enum.find(fn(x) -> get_in(x, ["name"]) == @test end)
    assert  is_delete_type == nil

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
    new_priority =  get_in(update_params, ["priority"]) + 1
    post(conn, "/api/operator_type/update_priority" ,%{"resource" =>  [%{"active" => true,
      "id" => get_in(update_params, ["id"]), "name" => get_in(update_params, ["name"]),
      "priority" => new_priority}]})
    new_priority
  end

  defp deactivate_operator_type(operator_type_info, conn) do
     post(conn, "/api/operator_type/deactivate/", %{"resource" => %{"operator_type_id" => get_in(operator_type_info,
       ["id"]), "active" => false}})
  end

  defp delete_operator(operator_type_info, conn) do
    url_info = "/api/operator_type/" <> get_in(operator_type_info,["id"])
    delete(conn, url_info)
  end
end