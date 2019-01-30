defmodule MgLoggerTest do
  use ExUnit.Case
  doctest MgLogger

  test "greets the world" do
    assert MgLogger.hello() == :world
  end
end
