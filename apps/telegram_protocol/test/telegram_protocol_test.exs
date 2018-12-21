defmodule TelegramProtocolTest do
  use ExUnit.Case
  doctest TelegramProtocol

  test "greets the world" do
    assert TelegramProtocol.hello() == :world
  end
end
