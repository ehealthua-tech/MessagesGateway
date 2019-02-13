defmodule SmsRouterTest do
  use ExUnit.Case
  alias SmsRouter.RedisManager
  doctest SmsRouter

  @sys_config %{default_sms_operator: "", org_name: "test", sending_time: "60", automatic_prioritization: false,
    messages_router_module: __MODULE__, messages_router_method: "send"}

  @sms_protocol_1 %{active: true, active_protocol_type: true,
    limit: 1000, operator_priority: 1, priority: 1, configs: %{sms_price_for_external_operator: 11,  code: "+38067"},
    protocol_name: "first_sms_protocol", module_name: __MODULE__, method_name: "first_sms_protocol", id: nil}


  @sms_protocol_2 %{active: true, active_protocol_type: true,  limit: 1000, operator_priority: 1, priority: 1,
    configs: %{sms_price_for_external_operator: 11,  code: "+38000"},
    protocol_name: "second_sms_protocol", module_name: __MODULE__, method_name: "second_sms_protocol", id: nil}

  @sms_info %{message_id: "a6ebd966-11a5-4f50-1111-9fc00a3b8469",
    contact: "+380000000000",
    body: "test",
    priority_list: [@sms_protocol_1, @sms_protocol_2], active: true,
    sending_status: "sending"}

  @operators_config [@sms_protocol_1, @sms_protocol_2]

  test "sms_router" do

    message_id = "test_id678"
    RedisManager.set("system_config", @sys_config)
    RedisManager.set(message_id, %{message_id: message_id, contact: "+380500000000",
      body: "test message", callback_url: "", priority_list: [], active: true, sending_status: "in_queue"})

    assert :ok == SmsRouter.check_and_send(%{contact: "+380500000000", body: "test message", message_id: message_id})
    RedisManager.del("system_config")
    RedisManager.keys("system_config")
    RedisManager.del("system_config1")
  end

  test "select operators sms_router" do

    RedisManager.set("system_config", @sys_config)
    RedisManager.set(get_in(@sms_protocol_1, [:protocol_name]), @sms_protocol_1)
    RedisManager.set(get_in(@sms_protocol_2, [:protocol_name]), @sms_protocol_2)
    RedisManager.set("operators_config", @operators_config)
    RedisManager.set(get_in(@sms_info, [:message_id]), @sms_info)

    assert :second_sms_protocol == SmsRouter.check_and_send(@sms_info)
    RedisManager.del("system_config")
    RedisManager.keys("system_config")
    RedisManager.del("system_config1")
  end

  def send(_), do: :ok

  def first_sms_protocol(_),  do: :first_sms_protocol
  def second_sms_protocol(_),  do: :second_sms_protocol

end
