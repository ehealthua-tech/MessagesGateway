defmodule LifecellSmsProtocol.CronManager do
  @moduledoc false
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_info({:check_status, message_info}, state) do
    #@todo add add messages to redis
    LifecellSmsProtocol.check_message_status(message_info)
    {:noreply, state}
  end

  defp schedule_work(message_info) do
    #@todo add change messages from redis
    Process.send_after(self(), {:check_status, message_info}, to_int(message_info.check_sms_status_time))
  end

end
