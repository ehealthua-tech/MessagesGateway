defmodule LifecellSmsProtocolTest do
  use ExUnit.Case
  doctest LifecellSmsProtocol

  test "greets the world" do
    assert LifecellSmsProtocol.hello() == :world
  end
end
