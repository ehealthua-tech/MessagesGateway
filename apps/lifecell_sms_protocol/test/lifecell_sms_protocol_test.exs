defmodule LifecellSmsProtocolTest do
  use ExUnit.Case
  doctest LifecellSmsProtocol

  test "test_redis" do
    LifecellSmsProtocol.RedisManager.set("test", "test")
    assert "test" = LifecellSmsProtocol.RedisManager.get("test")
    LifecellSmsProtocol.RedisManager.del("test")
    assert {:ok, 0} ==  LifecellSmsProtocol.RedisManager.del("test")
    assert {:error, :not_found} = LifecellSmsProtocol.RedisManager.get("test")
  end

  test "message test" do
    assert :ok ==  LifecellSmsProtocol.send_message(%{contact: "12345", body: "test", message_id: "123"})
  end

end
