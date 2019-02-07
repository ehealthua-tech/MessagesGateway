defmodule SmsRouterTest do
  use ExUnit.Case
  alias SmsRouter.RedisManager
  doctest SmsRouter

  test "greets the world" do

    message_id = "test_id678"
    RedisManager.set(message_id, %{message_id: message_id, contact: "+380632688304",
      body: "test message", callback_url: "", priority_list: [], active: true, sending_status: "in_queue"})

    assert :ok == SmsRouter.check_and_send(%{contact: "+380632688304", body: "test message", message_id: message_id})
  end
end
