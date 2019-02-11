defmodule TelegramProtocolTest do
  use ExUnit.Case
  doctest TelegramProtocol

  test "test_redis" do
    TelegramProtocol.RedisManager.set("test", "test")
    assert "test" = TelegramProtocol.RedisManager.get("test")
    assert {:ok, ["test"]} == TelegramProtocol.RedisManager.keys("test")
    TelegramProtocol.RedisManager.del("test")
    assert {:ok, 0} ==  TelegramProtocol.RedisManager.del("test")
    assert {:error, :not_found} = TelegramProtocol.RedisManager.get("test")
  end

  test "send message" do
    assert :ok == TelegramProtocol.send_message(%{message_id: "1234", contact: "+380632688394", body: "test body"})
    TelegramProtocol.start_telegram_lib()
    :timer.sleep(4000)
  end

end
