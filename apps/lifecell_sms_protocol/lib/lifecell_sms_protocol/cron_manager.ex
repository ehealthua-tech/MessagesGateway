defmodule LifecellSms.CronManager do
  @moduledoc false
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:resend_message, state) do
    # do important stuff
    IO.puts "Important stuff in progress..."
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work(message_info) do

    Process.send_after(self(), :resend_message, 1_000)
  end

  defp resend_message() do

  end

end
