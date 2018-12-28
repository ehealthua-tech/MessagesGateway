defmodule SmsRouterTest do
  use ExUnit.Case
  doctest SmsRouter

  test "greets the world" do
    assert SmsRouter.hello() == :world
  end
end
