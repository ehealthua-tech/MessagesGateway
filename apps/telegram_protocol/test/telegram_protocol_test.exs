defmodule TelegramProtocolTest do
  use ExUnit.Case
  doctest TelegramProtocol

  test "send message" do
   # assert :ok == TelegramProtocol.send_message(%{message_id: "1234", contact: "+380632688394", body: "test body"})
  end

  test "test_redis" do
    TelegramProtocol.RedisManager.set("test", "test")
    assert "test" = TelegramProtocol.RedisManager.get("test")
    assert {:ok, ["test"]} == TelegramProtocol.RedisManager.keys("test")
    TelegramProtocol.RedisManager.del("test")
    assert {:ok, 0} ==  TelegramProtocol.RedisManager.del("test")
    assert {:error, :not_found} = TelegramProtocol.RedisManager.get("test")
  end

end
