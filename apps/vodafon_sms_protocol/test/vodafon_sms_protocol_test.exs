defmodule VodafonSmsProtocolTest do
  use ExUnit.Case
  doctest VodafonSmsProtocol

  test "app start" do
    VodafonSmsProtocol.Application.start(nil,nil)
    VodafonSmsProtocol.start_link()
    VodafonSmsProtocol.init(nil)
  end

  test "test_redis" do
    VodafonSmsProtocol.RedisManager.set("test", "test")
    assert "test" = VodafonSmsProtocol.RedisManager.get("test")
    VodafonSmsProtocol.RedisManager.del("test")
    assert {:ok, 0} ==  VodafonSmsProtocol.RedisManager.del("test")
    assert {:error, :not_found} = VodafonSmsProtocol.RedisManager.get("test")
  end

end
