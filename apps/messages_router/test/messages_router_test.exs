defmodule MessagesRouterTest do
  use ExUnit.Case
  doctest MessagesRouter

  @sys_config %{default_sms_operator: "", org_name: "test", sending_time: "60", automatic_prioritization: false,
    sms_router_module: __MODULE__, sms_router_method: "send"}

  @sys_config_automation_priority %{default_sms_operator: "", org_name: "test", sending_time: "60",
    automatic_prioritization: true, sms_router_module: __MODULE__, sms_router_method: "send"}

  @smtp_protocol_config   %{module_name: __MODULE__, method_name: "send"}

  @smtp_protocol_name "smtp_protocol2"
  @sms_protocol_name "sms_protocol"


  @test_not_active_message %{message_id: "a6ebd966-11a5-4f50-b89d-9fc00a3b8469",
    contact: "test@skywerll.software",
    body: "12345mmm56565659", callback_url: "",
    priority_list: [
      %{active: true, active_protocol_type: true,
        configs: %{host: "blabal"},
        limit: 1000, operator_priority: 1, priority: 1,
        protocol_name: "smtp_protocol2"}], subject: "new subject12345", active: true,
    sending_status: "delivered"}

  @test_no_active_protocol %{message_id: "a6ebd966-11a5-4f50-b89d-9fc00a3b8469",
    contact: "test@skywerll.software",
    body: "12345mmm56565659", callback_url: "",
    priority_list: [
      %{active: false, active_protocol_type: true,
        configs: %{host: "blabal"},
        limit: 1000, operator_priority: 1, priority: 1,
        protocol_name: "smtp_protocol2"}], subject: "new subject12345", active: true,
    sending_status: "sending"}

  @test_empty_priority_list %{message_id: "a6ebd966-11a5-4f50-b89d-9fc00a3b8468",
    contact: "test@skywerll.software",
    body: "12345mmm56565659", callback_url: "",
    priority_list: [], subject: "new subject12345", active: true,
    sending_status: "sending"}

  @test_manual_priority %{message_id: "a6ebd966-11a5-4f50-b89d-9fc00a3b8469",
    contact: "test@skywerll.software",
    body: "12345mmm56565659", callback_url: "",
    priority_list: [
      %{active: true, active_protocol_type: true,
        configs: %{host: "blabal"},
        limit: 1000, operator_priority: 1, priority: 1,
        protocol_name: "smtp_protocol2"}], subject: "new subject12345", active: true,
    sending_status: "sending"}

  @test_sms_manual_priority %{message_id: "a6ebd966-11a5-4f50-1111-9fc00a3b8469",
    contact: "+380000000000",
    body: "test",
    priority_list: [
      %{active: true, active_protocol_type: true,
        configs: %{host: "blabal"},
        limit: 1000, operator_priority: 1, priority: 1,
        protocol_name: "sms_protocol"}], active: true,
    sending_status: "sending"}

  @test_automation_priority %{message_id: "a6ebd966-11a5-4f50-b89d-9fc00a3b8469",
    contact: "test@skywerll.software",
    body: "12345mmm56565659", callback_url: "",
    priority_list: [
      %{active: true, active_protocol_type: true,
        configs: %{host: "blabal"},
        limit: 1000, operator_priority: 1, priority: 1,
        protocol_name: "smtp_protocol2"}], subject: "new subject12345", active: true,
    sending_status: "sending"}

  @sms_protocol %{active: true, active_protocol_type: true, code: "+38067",
    configs: %{host: "blabal"},
    limit: 1000, operator_priority: 1, priority: 1,
    protocol_name: "sms_protocol", code: "+38000",  module_name: __MODULE__, method_name: "send"}

  @sms_protocol_1 %{active: true, active_protocol_type: true,
    limit: 1000, operator_priority: 1, priority: 1, sms_price_for_external_operator: 10, code: "+38067",
    protocol_name: "first_sms_protocol", module_name: __MODULE__, method_name: "first_sms_protocol"}

  @sms_protocol_2 %{active: true, active_protocol_type: true, code: "+38000",
    limit: 1000, operator_priority: 1, priority: 1, configs: %{sms_price_for_external_operator: 11},
    protocol_name: "second_sms_protocol", module_name: __MODULE__, method_name: "second_sms_protocol"}

  @sms_protocol_2_no_active %{active: false, active_protocol_type: true, code: "+38000",
    limit: 1000, operator_priority: 1, priority: 1,  configs: %{sms_price_for_external_operator: 11},
    protocol_name: "second_sms_protocol", module_name: __MODULE__, method_name: "second_sms_protocol"}

  @test_sms_automation_priority_with_empty_lists %{message_id: "a6ebd966-11a5-4f50-1111-9fc00a3b8469",
    contact: "+380000000000",
    body: "test",
    priority_list: [@sms_protocol_1], active: true,
    sending_status: "sending"}

  @test_sms_automation_priority  %{message_id: "a6ebd966-11a5-4f50-1111-9fc00a3b8469",
    contact: "+380000000000",
    body: "test",
    priority_list: [@sms_protocol], active: true,
    sending_status: "sending"}

  @test_sms_automation_priority_no_active  %{message_id: "a6ebd966-11a5-4f50-1111-9fc00a3b8469",
    contact: "+380000000000",
    body: "test",
    priority_list: [@sms_protocol_2_no_active], active: true, callback_url: "",
    sending_status: "sending"}


  @operators_config_name "operators_config"
  @operators_config [@sms_protocol_2]
  @operators_config_no_active  [@sms_protocol_2_no_active]

  test "app start" do
    MessagesRouter.Application.start(nil,nil)
  end

  test "send_message_manual_priority" do
    MessagesRouter.RedisManager.set("system_config", @sys_config)
    MessagesRouter.RedisManager.set(@smtp_protocol_name, @smtp_protocol_config)
    MessagesRouter.RedisManager.set(Map.get(@test_manual_priority, :message_id), @test_manual_priority)
    assert :ok == MessagesRouter.send_message(@test_manual_priority)
    MessagesRouter.RedisManager.del(Map.get(@test_manual_priority, :message_id))

    assert {:ok, 1} == delete_from_redis("system_config")
    assert {:ok, 1} == delete_from_redis(@smtp_protocol_name)
  end

  test "send_message_as_sms_manual_priority" do
    MessagesRouter.RedisManager.set("system_config", @sys_config)
    MessagesRouter.RedisManager.set(Map.get(@test_sms_manual_priority, :message_id), @test_sms_manual_priority)
    MessagesRouter.RedisManager.set(@sms_protocol_name, @smtp_protocol_config)
    assert :ok == MessagesRouter.send_message(@test_sms_manual_priority)
    MessagesRouter.RedisManager.del(Map.get(@test_sms_manual_priority, :message_id))
    assert {:ok, 1} == delete_from_redis("system_config")
    assert {:ok, 1} == delete_from_redis(@sms_protocol_name)
  end

  test "send_message_automation_priority" do
    MessagesRouter.RedisManager.set("system_config", @sys_config_automation_priority)
    MessagesRouter.RedisManager.set(Map.get(@test_automation_priority, :message_id), @test_automation_priority)
    MessagesRouter.RedisManager.set(@smtp_protocol_name, @smtp_protocol_config)
    assert :ok == MessagesRouter.send_message(@test_automation_priority)
    MessagesRouter.RedisManager.del(Map.get(@test_automation_priority, :message_id))
    assert {:ok, 1} == delete_from_redis("system_config")
    assert {:ok, 1} == delete_from_redis(@smtp_protocol_name)
  end

  test "send_sms_automation_priority_with_empty_lists" do
    MessagesRouter.RedisManager.set("system_config", @sys_config_automation_priority)
    MessagesRouter.RedisManager.set(@operators_config_name, @operators_config)
    MessagesRouter.RedisManager.set(Map.get(@sms_protocol_1, :protocol_name), @sms_protocol_1)
    MessagesRouter.RedisManager.set(Map.get(@sms_protocol_2, :protocol_name), @sms_protocol_2)
    MessagesRouter.RedisManager.set(Map.get(@test_sms_automation_priority_with_empty_lists, :message_id),
      @test_sms_automation_priority_with_empty_lists)
    assert :second_sms_protocol == MessagesRouter.send_message(@test_sms_automation_priority_with_empty_lists)
    MessagesRouter.RedisManager.del(Map.get(@test_sms_automation_priority_with_empty_lists, :message_id))
    assert {:ok, 1} == delete_from_redis("system_config")
    assert {:ok, 1} == delete_from_redis(@operators_config_name)
    assert {:ok, 1} == delete_from_redis(Map.get(@sms_protocol_1, :protocol_name))
    assert {:ok, 1} == delete_from_redis(Map.get(@sms_protocol_2, :protocol_name))
  end

  test "send_sms_automation_priority" do
    MessagesRouter.RedisManager.set("system_config", @sys_config_automation_priority)
    MessagesRouter.RedisManager.set(@operators_config_name, @operators_config)
    MessagesRouter.RedisManager.set(Map.get(@sms_protocol, :protocol_name), @sms_protocol)
    MessagesRouter.RedisManager.set(Map.get(@test_sms_automation_priority, :message_id), @test_sms_automation_priority)
    assert :ok == MessagesRouter.send_message(@test_sms_automation_priority)
    MessagesRouter.RedisManager.del(Map.get(@test_sms_automation_priority, :message_id))
    assert {:ok, 1} == delete_from_redis("system_config")
    assert {:ok, 1} == delete_from_redis(@operators_config_name)
    assert {:ok, 1} == delete_from_redis(Map.get(@sms_protocol, :protocol_name))
  end

  test "send_sms_automation_priority_no_active" do
    MessagesRouter.RedisManager.set("system_config", @sys_config_automation_priority)
    MessagesRouter.RedisManager.set(@operators_config_name, @operators_config_no_active)
    MessagesRouter.RedisManager.set(Map.get(@sms_protocol_2_no_active, :protocol_name), @sms_protocol_2_no_active)
    MessagesRouter.RedisManager.set(Map.get(@test_sms_automation_priority_no_active, :message_id), @test_sms_automation_priority_no_active)
    assert :ok == MessagesRouter.send_message(@test_sms_automation_priority_no_active)
    MessagesRouter.RedisManager.del(Map.get(@test_sms_automation_priority_no_active, :message_id))
    assert {:ok, 1} == delete_from_redis("system_config")
    assert {:ok, 1} == delete_from_redis(@operators_config_name)
    assert {:ok, 1} == delete_from_redis(Map.get(@sms_protocol_2_no_active, :protocol_name))
  end

  test "try_send_not_active_message" do
    MessagesRouter.RedisManager.set(Map.get(@test_not_active_message, :message_id), @test_not_active_message)
    MessagesRouter.send_message(@test_not_active_message)
    res = MessagesRouter.RedisManager.get(Map.get(@test_not_active_message, :message_id))
    assert false == res.active
    MessagesRouter.RedisManager.del(Map.get(@test_not_active_message, :message_id))
  end

  test "try_send_message_empty_priority_list" do
    MessagesRouter.RedisManager.set(Map.get(@test_empty_priority_list, :message_id), @test_empty_priority_list)
    MessagesRouter.send_message(@test_empty_priority_list)
    res =  MessagesRouter.RedisManager.get(Map.get(@test_empty_priority_list, :message_id))
    assert false == res.active
    MessagesRouter.RedisManager.del(Map.get(@test_empty_priority_list, :message_id))
  end

  test "try_send_message_to_no_active_protocol" do
    MessagesRouter.RedisManager.set("system_config", @sys_config_automation_priority)
    MessagesRouter.RedisManager.set(Map.get(@test_no_active_protocol, :message_id), @test_no_active_protocol)
    MessagesRouter.send_message(@test_no_active_protocol)
    res =  MessagesRouter.RedisManager.get(Map.get(@test_no_active_protocol, :message_id))
    assert false == res.active
    MessagesRouter.RedisManager.del(Map.get(@test_no_active_protocol, :message_id))
    assert {:ok, 1} == delete_from_redis("system_config")
  end

  test "test_redis" do
    MessagesRouter.RedisManager.set("test", "test")
    assert "test" = MessagesRouter.RedisManager.get("test")
    MessagesRouter.RedisManager.del("test")
    assert {:ok, 0} ==  MessagesRouter.RedisManager.del("test")
    assert {:error, :not_found} = MessagesRouter.RedisManager.get("test")
  end

  def send(_), do: :ok
  def first_sms_protocol(_), do: :first_sms_protocol
  def second_sms_protocol(_), do: :second_sms_protocol

  defp delete_from_redis(key) do
    MessagesRouter.RedisManager.del(key)
  end

end
