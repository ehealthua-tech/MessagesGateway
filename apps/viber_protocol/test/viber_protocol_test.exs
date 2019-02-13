defmodule ViberProtocolTest do
  use ExUnit.Case
  doctest ViberProtocol
  use DbAgent.DataCase

  test "message test" do
    assert ViberProtocol.send_message(%{message_id: "1234", contact: "+380632688394", body: "test body"})
  end

  test "test_redis" do
    ViberProtocol.RedisManager.set("test", "test")
    assert "test" = ViberProtocol.RedisManager.get("test")
    ViberProtocol.RedisManager.del("test")
    assert {:ok, 0} ==  ViberProtocol.RedisManager.del("test")
    assert {:error, :not_found} = ViberProtocol.RedisManager.get("test")
  end

end
