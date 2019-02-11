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

end
