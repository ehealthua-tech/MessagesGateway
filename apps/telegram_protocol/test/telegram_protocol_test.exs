defmodule TelegramProtocolTest do
  use ExUnit.Case, async: false
  doctest TelegramProtocol

  @sys_config %{default_sms_operator: "", org_name: "test", sending_time: "60", automatic_prioritization: false,
    sms_router_module: __MODULE__, sms_router_method: "send"}

  @messages_gateway_conf "system_config"

  @telegram_protocol_config   %{
    api_hash: "1a6a0ad0726805c353f26b5f859ea279",
    api_id: "539444",
    code: "",
    password: "",
    phone: "+380674294504",
    session_name: "ehealth",
    module_name: __MODULE__,
    method_name: "send"}

  @telegram_protocol_name "telegram_protocol"

  @test_manual_priority %{message_id: "a6ebd966-11a5-4f50-b89d-9fc00a3b8469",
    contact: "+380632688394",
    body: "12345mmm56565659", callback_url: "",
    priority_list: [
      %{active: true, active_protocol_type: true,
        configs: %{host: "blabal"},
        limit: 1000, operator_priority: 1, priority: 1,
        protocol_name: "telegram_protocol"}], active: true,
    sending_status: "sending"}

  test "test_redis" do
    TelegramProtocol.RedisManager.set("test", "test")
    assert "test" = TelegramProtocol.RedisManager.get("test")
    assert {:ok, ["test"]} == TelegramProtocol.RedisManager.keys("test")
    TelegramProtocol.RedisManager.del("test")
    assert {:ok, 0} ==  TelegramProtocol.RedisManager.del("test")
    assert {:error, :not_found} = TelegramProtocol.RedisManager.get("test")
  end

  test "message test" do
    old_config = TelegramProtocol.RedisManager.get(@messages_gateway_conf)
    old_protocol_config = TelegramProtocol.RedisManager.get(@telegram_protocol_name)
    TelegramProtocol.RedisManager.set(@messages_gateway_conf, @sys_config)
    TelegramProtocol.RedisManager.set(@telegram_protocol_name, @telegram_protocol_config)
    id = Map.get(@test_manual_priority, :message_id)
    TelegramProtocol.RedisManager.set(id, @test_manual_priority)
    #  TelegramProtocol.start_telegram_lib()
    TelegramProtocol.send_message(%{body: Map.get(@test_manual_priority, :body), contact: Map.get(@test_manual_priority, :contact), message_id: id})
    TelegramProtocol.RedisManager.set(@messages_gateway_conf, old_config)
    TelegramProtocol.RedisManager.set(@telegram_protocol_name, old_protocol_config)
    :timer.sleep(4000)
    TelegramProtocol.RedisManager.del(id)
  end

  def send(_value), do: :ok


end
