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
    session_name: "ehealth",
    module_name: __MODULE__,
    method_name: "send"}

  @telegram_protocol_name "telegram_protocol"

  @test_manual_priority %{message_id: "a6ebd966-11a5-4f50-b89d-9fc00a3b82222",
    contact: "+380630000000",
    body: "12345mmm56565659", callback_url: "",
    priority_list: [ ], active: true,
    sending_status: "sending",module_name: __MODULE__,  method_name: "send"}

  @test_manual_priority2 %{message_id: "a6ebd966-11a5-4f50-b89d-9fc00a3b83333",
    contact: "+380630000000",
    body: "12345mmm56565659", callback_url: "",
    priority_list: [
      %{active: true, active_protocol_type: true,
        configs: %{host: "blabal"},
        limit: 1000, operator_priority: 1, priority: 1,
        protocol_name: "telegram_protocol"}], active: true,
    sending_status: "sending",module_name: __MODULE__,  method_name: "send"}
  test "test_redis" do
    TelegramProtocol.RedisManager.set("test", "test")
    assert "test" = TelegramProtocol.RedisManager.get("test")
    assert {:ok, ["test"]} == TelegramProtocol.RedisManager.keys("test")
    TelegramProtocol.RedisManager.del("test")
    assert {:ok, 0} ==  TelegramProtocol.RedisManager.del("test")
    assert {:error, :not_found} = TelegramProtocol.RedisManager.get("test")
  end

  test "app start" do
    TelegramProtocol.Application.start(nil,nil)
    TelegramProtocol.start_link()
    TelegramProtocol.init(nil)
  end

  @user_id "1"
  @chat_id "2"
  test "telegram protocol message send" do

    TelegramProtocol.RedisManager.set(@messages_gateway_conf, @sys_config)
    TelegramProtocol.RedisManager.set(@telegram_protocol_name, @telegram_protocol_config)

    TelegramProtocol.RedisManager.set(get_in(@test_manual_priority, [:message_id]), @test_manual_priority)
    TelegramProtocol.send_message(@test_manual_priority)
    assert {:error, :not_found} != TelegramProtocol.RedisManager.get(get_in(@test_manual_priority, [:message_id]))

    telegram_process = Process.whereis(:'Elixir.TelegramProtocol')
    Kernel.send(telegram_process, {:recv, %Object.ImportedContacts{user_ids: [@user_id], importer_count: "1"}})
    Kernel.send(telegram_process, {:recv, %Object.User{id: @user_id, phone_number: "380630000000", type: %Object.UserTypeRegular{}}})
    Kernel.send(telegram_process, {:recv, %Object.Chat{id: @chat_id, type: %Object.ChatTypePrivate{user_id: @user_id}}})
    Kernel.send(telegram_process, {:recv, %Object.UpdateChatReadOutbox{chat_id: @chat_id}})
    :timer.sleep(2000)

    res = TelegramProtocol.RedisManager.get(get_in(@test_manual_priority, [:message_id]))
    assert res.sending_status == "read"
    assert {:ok, 1} ==  TelegramProtocol.RedisManager.del(get_in(@test_manual_priority, [:message_id]))
    assert {:error, :not_found} = TelegramProtocol.RedisManager.get(get_in(@test_manual_priority, [:message_id]))
    assert {:ok, 1} == TelegramProtocol.RedisManager.del(@messages_gateway_conf)
    assert {:ok, 1} == TelegramProtocol.RedisManager.del(@telegram_protocol_name)
  end

  test "telegram protocol message didn`t send" do

    TelegramProtocol.RedisManager.set(@messages_gateway_conf, @sys_config)
    TelegramProtocol.RedisManager.set(@telegram_protocol_name, @telegram_protocol_config)

    TelegramProtocol.RedisManager.set(get_in(@test_manual_priority2, [:message_id]), @test_manual_priority2)
    TelegramProtocol.send_message(@test_manual_priority2)
    assert {:error, :not_found} != TelegramProtocol.RedisManager.get(get_in(@test_manual_priority2, [:message_id]))

    telegram_process = Process.whereis(:'Elixir.TelegramProtocol')
    Kernel.send(telegram_process, {:recv, %Object.ImportedContacts{user_ids: ["0"], importer_count: "1"}})

    :timer.sleep(4000)
    res = TelegramProtocol.RedisManager.get(get_in(@test_manual_priority2, [:message_id]))
    assert res.sending_status == "sending Telegram error"
    assert {:ok, 1} ==  TelegramProtocol.RedisManager.del(get_in(@test_manual_priority2, [:message_id]))
    assert {:error, :not_found} = TelegramProtocol.RedisManager.get(get_in(@test_manual_priority2, [:message_id]))

    assert {:ok, 1} == TelegramProtocol.RedisManager.del(@messages_gateway_conf)
    assert {:ok, 1} == TelegramProtocol.RedisManager.del(@telegram_protocol_name)
  end

  test "telegram protocol check config" do
    TelegramProtocol.RedisManager.get(@telegram_protocol_name)
    |> TelegramProtocol.check_config()

    res = TelegramProtocol.RedisManager.get(@telegram_protocol_name)
    assert Map.has_key?(res, :phone) == true

    TelegramProtocol.RedisManager.set(@telegram_protocol_name, @telegram_protocol_config)
    updated_res = TelegramProtocol.RedisManager.get(@telegram_protocol_name)
    assert Map.has_key?(updated_res, :phone) == false

    TelegramProtocol.check_config(updated_res)

    return_res = TelegramProtocol.RedisManager.get(@telegram_protocol_name)
    assert Map.has_key?(return_res, :phone) == true

    assert {:ok, 1} == TelegramProtocol.RedisManager.del(@telegram_protocol_name)

  end

  def send(_value), do: :ok


end
