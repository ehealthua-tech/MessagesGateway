defmodule MessagesRouterTest do
  use ExUnit.Case
  doctest MessagesRouter

  test "greets the world" do
    assert MessagesRouter.hello() == :world
  end
end
