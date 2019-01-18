defmodule VodafonSmsProtocolTest do
  use ExUnit.Case
  doctest VodafonSmsProtocol

  test "greets the world" do
    assert VodafonSmsProtocol.hello() == :world
  end
end
