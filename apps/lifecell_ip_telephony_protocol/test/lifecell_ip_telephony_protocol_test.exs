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

  test "message test" do
    assert :ok == LifecellIpTelephonyProtocol.send_message(%{message_id: "1234", phone: "+380632688394"})
  end

end
