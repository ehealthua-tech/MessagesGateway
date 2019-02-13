defmodule TelegramProtocolTest do
  use ExUnit.Case, async: false
  doctest TelegramProtocol
  alias TDLib.Object

  @sys_config %{default_sms_operator: "", org_name: "test", sending_time: "60", automatic_prioritization: false,
    sms_router_module: __MODULE__, sms_router_method: "send"}

  @messages_gateway_conf "system_config"

  @telegram_protocol_config   %{
    api_hash: "1a6a0ad0726805c353f26b5f859ea279",
    api_id: "539444",
    code: "",
    password: "",
    phone: "+380670000000",
    session_name: "ehealth",
    module_name: __MODULE__,
    method_name: "send"}

  @telegram_protocol_name "telegram_protocol"

  @test_manual_priority %{message_id: "a6ebd966-11a5-4f50-b89d-9fc00a3b8469",
    contact: "+380630000000",
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

  @user_id "1"
  @chat_id "2"
  test "message test" do
    old_config = TelegramProtocol.RedisManager.get(@messages_gateway_conf)
    old_protocol_config = TelegramProtocol.RedisManager.get(@telegram_protocol_name)
    TelegramProtocol.RedisManager.set(@messages_gateway_conf, @sys_config)
    TelegramProtocol.RedisManager.set(@telegram_protocol_name, @telegram_protocol_config)


    TelegramProtocol.RedisManager.set(get_in(@test_manual_priority, [:message_id]), @test_manual_priority)
    TelegramProtocol.send_message(@test_manual_priority)

    telegram_process = Process.whereis(:'Elixir.TelegramProtocol')
    Kernel.send(telegram_process, {:recv, %Object.ImportedContacts{user_ids: [@user_id], importer_count: "1"}})
    Kernel.send(telegram_process, {:recv, %Object.User{id: @user_id, phone_number: "380630000000", type: %Object.UserTypeRegular{}}})
    Kernel.send(telegram_process, {:recv, %Object.Chat{id: @chat_id, type: %Object.ChatTypePrivate{user_id: @user_id}}})
    Kernel.send(telegram_process, {:recv, %Object.UpdateChatReadOutbox{chat_id: @chat_id}})


    TelegramProtocol.RedisManager.set(@messages_gateway_conf, old_config)
    TelegramProtocol.RedisManager.set(@telegram_protocol_name, old_protocol_config)
    TelegramProtocol.RedisManager.del(get_in(@test_manual_priority, [:message_id]))
  end


  def send(_value), do: :ok


end
