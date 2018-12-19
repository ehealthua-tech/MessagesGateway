defmodule ViberProtocolTest do
  use ExUnit.Case
  doctest ViberProtocol

  test "greets the world" do
    assert ViberProtocol.hello() == :world
  end
end
