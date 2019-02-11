defmodule LifecellIpTelephonyProtocolTest do
  use ExUnit.Case
  doctest LifecellIpTelephonyProtocol

  test "test_redis" do
    LifecellIpTelephonyProtocol.RedisManager.set("test", "test")
    assert "test" = LifecellIpTelephonyProtocol.RedisManager.get("test")
    LifecellIpTelephonyProtocol.RedisManager.del("test")
    assert {:ok, 0} ==  LifecellIpTelephonyProtocol.RedisManager.del("test")
    assert {:error, :not_found} = LifecellIpTelephonyProtocol.RedisManager.get("test")
  end

end
