defmodule MessagesRouterTest do
  use ExUnit.Case
  doctest MessagesRouter

  @sys_config %{default_sms_operator: "", org_name: "test", sending_time: "60", automatic_prioritization: false,
    sms_router_module: __MODULE__, sms_router_method: "send"}

  @sys_config_automation_priority %{default_sms_operator: "", org_name: "test", sending_time: "60",
    automatic_prioritization: true, sms_router_module: __MODULE__, sms_router_method: "send"}

  @smtp_protocol_config   %{module_name: __MODULE__, method_name: "send"}
  @smtp_protocol_name "smtp_protocol"

  @test_payload %{:body => "12345mmm56565656",:callback_url => "test@skywerll.software",
    :contact => "test@skywerll.software",
    :message_id => "a6ebd966-11a5-4f50-b89d-9fc00a3b8464",
    :priority_list =>
      [%{:active => true, :active_protocol_type => true,
      :configs => %{:host => "blabal"},
      :limit => 1000, :operator_priority => 1,:priority => 1,
      :protocol_name => "smtp_protocol"}],
    :subject => "new subject12345"}

  @test_payload2 %{:body => "12345mmm56565656",:callback_url => "",
    :contact => "test@skywerll.software",
    :message_id => "a6ebd966-11a5-4f50-b89d-9fc00a3b8467",
    :priority_list =>
      [%{:active => false, :active_protocol_type => false,
      :configs => %{:host => "blabal"},
      :limit => 1000, :operator_priority => 1,:priority => 1,
      :protocol_name => "smtp_protocol"}],
    :subject => "new subject12345"}

  @test_payload3 %{:body => "12345mmm56565656",:callback_url => "",
    :contact => "test@skywerll.software",
    :message_id => "a6ebd966-11a5-4f50-b89d-9fc00a3b8468",
    :priority_list =>
      [%{:priority => 5}, %{:active => true, :active_protocol_type => true,
      :configs => %{:host => "blabal"},
      :limit => 1000, :operator_priority => 1,:priority => 1,
      :protocol_name => "smtp_protocol"}],
    :subject => "new subject12345"}

  @test_payload4 %{:body => "12345mmm56565659",:callback_url => "",
    :contact => "test@skywerll.software",
    :message_id => "a6ebd966-11a5-4f50-b89d-9fc00a3b8469",
    :priority_list =>
      [%{:active => false, :active_protocol_type => false,
      :configs => %{:host => "blabal"},
      :limit => 1000, :operator_priority => 1,:priority => 1,
      :protocol_name => "smtp_protocol"}],
    :subject => "new subject12345"}

  @test_not_active_message %{message_id: "a6ebd966-11a5-4f50-b89d-9fc00a3b8469",
    contact: "test@skywerll.software",
    body: "12345mmm56565659", callback_url: "",
    priority_list: [
      %{active: true, active_protocol_type: true,
        configs: %{host: "blabal"},
        limit: 1000, operator_priority: 1, priority: 1,
        protocol_name: "smtp_protocol"}], subject: "new subject12345", active: true,
    sending_status: "delivered"}

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
        protocol_name: "smtp_protocol"}], subject: "new subject12345", active: true,
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
        protocol_name: "smtp_protocol"}], subject: "new subject12345", active: true,
    sending_status: "sending"}


  test "send_message_manual_priority" do
    MessagesRouter.RedisManager.set("system_config", @sys_config)
    MessagesRouter.RedisManager.set(@smtp_protocol_name, @smtp_protocol_config)
    MessagesRouter.RedisManager.set(Map.get(@test_manual_priority, :message_id), @test_manual_priority)
    assert :ok == MessagesRouter.send_message(@test_manual_priority)
  end

  test "send_message_as_sms_manual_priority" do
    MessagesRouter.RedisManager.set("system_config", @sys_config)
    MessagesRouter.RedisManager.set(Map.get(@test_sms_manual_priority, :message_id), @test_sms_manual_priority)
    assert :ok == MessagesRouter.send_message(@test_sms_manual_priority)
  end

  test "send_message_automation_priority" do
    MessagesRouter.RedisManager.set("system_config", @sys_config_automation_priority)
    MessagesRouter.RedisManager.set(Map.get(@test_automation_priority, :message_id), @test_automation_priority)
    assert :ok == MessagesRouter.send_message(@test_automation_priority)
  end

  test "try_send_not_active_message" do
    MessagesRouter.RedisManager.set(Map.get(@test_not_active_message, :message_id), @test_not_active_message)
    MessagesRouter.send_message(@test_not_active_message)
    res = MessagesRouter.RedisManager.get(Map.get(@test_not_active_message, :message_id))
    assert false == res.active
  end

  test "try_send_message_empty_priority_list" do
    MessagesRouter.RedisManager.set(Map.get(@test_empty_priority_list, :message_id), @test_empty_priority_list)
    MessagesRouter.send_message(@test_empty_priority_list)
    res =  MessagesRouter.RedisManager.get(Map.get(@test_empty_priority_list, :message_id))
    assert false == res.active
  end

  def send(_), do: :ok

end
