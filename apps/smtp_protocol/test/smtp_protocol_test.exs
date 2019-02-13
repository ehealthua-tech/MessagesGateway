defmodule SmtpProtocolTest do
  use ExUnit.Case
  doctest SmtpProtocol

  @smtp_protocol_config   %{module_name: __MODULE__, method_name: "send"}

  @smtp_protocol_name "smtp_protocol"

  @test_manual_priority %{message_id: "a6ebd966-11a5-4f40-b89d-9fc00a3b8469",
    contact: "test123",
    subject: "test subj12",
    body: "12345mmm56565659", callback_url: "",
    priority_list: [
      %{active: true, active_protocol_type: true,
        configs: %{host: "blabal"},
        limit: 1000, operator_priority: 1, priority: 1,
        protocol_name: "smtp_protocol"}], active: true,
    sending_status: "sending"}

  test "email test" do
    old_protocol_config = SmtpProtocol.RedisManager.get(@smtp_protocol_name)
    id = Map.get(@test_manual_priority, :message_id)
    SmtpProtocol.RedisManager.set(id, @test_manual_priority)
    SmtpProtocol.send_email(@test_manual_priority)
    SmtpProtocol.RedisManager.del(id)
    SmtpProtocol.RedisManager.set(@smtp_protocol_name, old_protocol_config)
  end

  test "test_redis" do
    SmtpProtocol.RedisManager.set("test", "test")
    assert "test" = SmtpProtocol.RedisManager.get("test")
    SmtpProtocol.RedisManager.del("test")
    assert {:ok, 0} ==  SmtpProtocol.RedisManager.del("test")
    assert {:error, :not_found} = SmtpProtocol.RedisManager.get("test")
  end

  def send(_value), do: :ok

end
