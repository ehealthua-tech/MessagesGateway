defmodule MessagesRouterTest do
  use ExUnit.Case
  doctest MessagesRouter

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

test "messages_router" do

    MessagesRouter.RedisManager.set("a6ebd966-11a5-4f50-b89d-9fc00a3b8464", %{:active => true, :sending_status => true})
    assert :ok == MessagesRouter.send_message(@test_payload)
    MessagesRouter.RedisManager.del("a6ebd966-11a5-4f50-b89d-9fc00a3b8464")

    MessagesRouter.RedisManager.set("a6ebd966-11a5-4f50-b89d-9fc00a3b8467", %{:active => false, :sending_status => false})
    assert :ok == MessagesRouter.send_message(@test_payload2)
    MessagesRouter.RedisManager.del("a6ebd966-11a5-4f50-b89d-9fc00a3b8467")

    MessagesRouter.RedisManager.set("a6ebd966-11a5-4f50-b89d-9fc00a3b8468", %{:active => true, :sending_status => false})
    assert :ok == MessagesRouter.send_message(@test_payload3)
    MessagesRouter.RedisManager.del("a6ebd966-11a5-4f50-b89d-9fc00a3b8468")

    MessagesRouter.RedisManager.set("a6ebd966-11a5-4f50-b89d-9fc00a3b8469", %{:active => true, :sending_status => false})
    assert :ok == MessagesRouter.send_message(@test_payload4)
    MessagesRouter.RedisManager.del("a6ebd966-11a5-4f50-b89d-9fc00a3b8469")

    assert {:error, :not_found} ==  MessagesRouter.RedisManager.get("a6ebd966-11a5-4f50-b89d-9fc00a3b8")

  end
end
