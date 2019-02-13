defmodule MessagesGatewayWeb.MessageControllerTest do
  use MessagesGatewayWeb.ConnCase
  use DbAgent.DataCase

  test "send message without auth", %{conn: conn} do
    response = send_message(conn, 401, ["error", "message"])
    assert response == "Missing header authorization"
  end

  test "send message incorrect id and key", %{conn: conn} do
    response =
      add_auth_header("11111", "11111", conn)
      |> send_message(401, ["error", "message"])
    assert response == "Incorrect params for authorization"
  end

  test "send message correct id and incorrect key", %{conn: conn} do
    assert create_key(conn) == "success"
    [key|_] = select_all_keys(conn)
    response =
      add_auth_header(get_in(key, ["id"]), "11111", conn)
      |> send_message(401, ["error", "message"])
    assert response == "Incorrect key for authorization"
    remove_key(get_in(key, ["id"]), conn)
  end

  test "send message correct id and correct key", %{conn: conn} do
    assert create_key(conn) == "success"
    [key_couple | _] = select_all_keys(conn)
    key = Base.hex_encode32(:crypto.hash(:sha256, get_in(key_couple, ["key"])), case: :lower)
    new_conn = add_auth_header(get_in(key_couple, ["id"]), key, conn)
    response = send_message(new_conn, 200, ["data"])
    assert get_in(response, ["tag"]) == "111111111"
    assert check_status(get_in(response, ["message_id"]), new_conn) == "in_queue"

    assert change_message_status(get_in(response, ["message_id"]), new_conn) == "Status of sending was successfully changed"

    assert check_status(get_in(response, ["message_id"]), new_conn) == "success"

    remove_key(get_in(key_couple, ["id"]), conn)
  end

  test "send email correct id and correct key", %{conn: conn} do
    assert create_key(conn) == "success"
    [key_couple | _] = select_all_keys(conn)
    key = Base.hex_encode32(:crypto.hash(:sha256, get_in(key_couple, ["key"])), case: :lower)
    new_conn = add_auth_header(get_in(key_couple, ["id"]), key, conn)
    response = send_email(new_conn)
    assert get_in(response, ["tag"]) == "111111111"
    assert check_status(get_in(response, ["message_id"]), new_conn) == "in_queue"
    remove_key(get_in(key_couple, ["id"]), conn)
  end

  defp create_key(conn) do
    get(conn, "/api/keys")
    |> json_response(200)
    |> get_in(["data", "status"])
  end

  defp select_all_keys(conn) do
    get(conn, "/api/keys/all")
    |> json_response(200)
    |> get_in(["data", "keys"])
  end

  defp remove_key(id, conn) do
    delete(conn, "/api/keys/" <> id)
    |> json_response(200)
    |> get_in(["data", "status"])
  end

  defp add_auth_header(id, key, conn) do
    put_req_header(conn, "authorization", "Bearer "<> id <> ":" <> key)
  end

  defp send_message(conn, resp_status, keys) do
    post(conn, "/sending/message", %{"resource" => %{
      "tag" => "111111111",
      "contact" => "+3800000000000",
      "body" => "Ваш код для підтвердження 451"
    }})
    |> json_response(resp_status)
    |> get_in(keys)
  end

  defp check_status(message_id, conn) do
    post(conn, "/sending/status", %{"resource" => %{
      "message_id" => message_id
    }})
    |> json_response(200)
    |> get_in(["data", "message_status"])
  end

  defp send_email(conn) do
    post(conn, "/sending/email", %{"resource" => %{
      "tag" => "111111111",
      "email" => "test@u.u",
      "subject" => "subject",
      "body" => "Ваш код для підтвердження 451"
    }})
    |> json_response(200)
    |> get_in(["data"])
  end
  defp change_message_status(message_id, conn) do
    post(conn, "/sending/change_message_status", %{"resource" =>
    %{"message_id" => message_id, "sending_active" => "success"}})
    |> json_response(200)
    |> get_in(["data", "message"])
  end

end

defmodule MqManagerTest do
  def publish(_), do: :ok
end