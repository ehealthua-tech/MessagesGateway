defmodule ViberProtocolTest do
  use ExUnit.Case
  doctest ViberProtocol
  use DbAgent.DataCase

  @sys_config %{default_sms_operator: "", org_name: "test", sending_time: "60", automatic_prioritization: false,
    sms_router_module: __MODULE__, sms_router_method: "send"}

  @messages_gateway_conf "system_config"

  @viber_protocol_config   %{module_name: __MODULE__, method_name: "send"}

  @viber_protocol_name "viber_protocol"

  @test_manual_priority %{message_id: "a6ebd966-11a5-4f50-b89d-9fc00a3b8469",
    contact: "test123",
    body: "12345mmm56565659", callback_url: "",
    priority_list: [
      %{active: true, active_protocol_type: true,
        configs: %{host: "blabal"},
        limit: 1000, operator_priority: 1, priority: 1,
        protocol_name: "viber_protocol"}], active: true,
    sending_status: "sending"}

  test "test_redis" do
    ViberProtocol.RedisManager.set("test", "test")
    assert "test" = ViberProtocol.RedisManager.get("test")
    ViberProtocol.RedisManager.del("test")
    assert {:ok, 0} ==  ViberProtocol.RedisManager.del("test")
    assert {:error, :not_found} = ViberProtocol.RedisManager.get("test")
  end

  test "message test" do
    old_config = ViberProtocol.RedisManager.get(@messages_gateway_conf)
    old_protocol_config = ViberProtocol.RedisManager.get(@viber_protocol_name)
    ViberProtocol.RedisManager.set(@messages_gateway_conf, @sys_config)
    ViberProtocol.RedisManager.set(@viber_protocol_name, @viber_protocol_config)
    id = Map.get(@test_manual_priority, :message_id)
    ViberProtocol.RedisManager.set(id, @test_manual_priority)
    ViberProtocol.send_message(%{contact: Map.get(@test_manual_priority, :contact), message_id: id})
    ViberProtocol.RedisManager.del(id)
    ViberProtocol.RedisManager.set(@messages_gateway_conf, old_config)
    ViberProtocol.RedisManager.set(@viber_protocol_name, old_protocol_config)
  end

  def send(_value), do: :ok

end
