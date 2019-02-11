defmodule SmtpProtocolTest do
  use ExUnit.Case
  doctest SmtpProtocol

  test "email test" do
    SmtpProtocol.send_email(%{message_id: "123", contact: "itilmand@gmail.com", body: "test", subject: " test subject"})
    SmtpProtocol.Email.email("itilmand@gmail.com", "test sub", "test123") |> SmtpProtocol.Mailer.deliver_now
  end

  test "test_redis" do
    SmtpProtocol.RedisManager.set("test", "test")
    assert "test" = SmtpProtocol.RedisManager.get("test")
    SmtpProtocol.RedisManager.del("test")
    assert {:ok, 0} ==  SmtpProtocol.RedisManager.del("test")
    assert {:error, :not_found} = SmtpProtocol.RedisManager.get("test")
  end


end
