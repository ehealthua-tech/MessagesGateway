defmodule SmtpProtocolTest do
  use ExUnit.Case
  doctest SmtpProtocol

  test "greets the world" do
    assert SmtpProtocol.hello() == :world
  end
end
