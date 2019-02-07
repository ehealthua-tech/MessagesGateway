defmodule SmsRouterTest do
  use ExUnit.Case
  alias SmsRouter.RedisManager
  doctest SmsRouter

  @sys_config %{default_sms_operator: "", org_name: "test", sending_time: "60", automatic_prioritization: false,
    messages_router_module: __MODULE__, messages_router_method: "send"}

  test "sms_router" do

    message_id = "test_id678"
    RedisManager.set("system_config", @sys_config)
    RedisManager.set(message_id, %{message_id: message_id, contact: "+380632688394",
      body: "test message", callback_url: "", priority_list: [], active: true, sending_status: "in_queue"})

    assert :ok == SmsRouter.check_and_send(%{contact: "+380632688304", body: "test message", message_id: message_id})
    RedisManager.del("system_config")
    RedisManager.keys("system_config")
    RedisManager.del("system_config1")
  end

  def send(_), do: :ok

end
