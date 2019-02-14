defmodule MgLoggerTest do
  use ExUnit.Case

  test "log test" do
    assert :ok == GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{__MODULE__ => "test"}})
    assert :ok == MgLogger.Server.terminate(:test, :ok)
  end
end
