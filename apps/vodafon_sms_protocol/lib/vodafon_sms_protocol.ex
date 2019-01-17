defmodule VodafonSmsProtocol do
  @moduledoc """
  Documentation for VodafonSmsProtocol.
  """

  use GenServer
  alias VodafonSmsProtocol.RedisManager


  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do

    {:ok, []}

  end
end
