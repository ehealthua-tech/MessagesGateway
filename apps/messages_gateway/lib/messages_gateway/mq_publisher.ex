defmodule MessagesGateway.MqPublisher do
  use GenServer
  use AMQP

  @reconnect_timeout 5000
  @exchange    "message_exchange"
  @queue       "message_queue"

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    state = %{connected: false, chan: nil, queue_name: @queue, conn: nil}
    {:ok, connect(state)}
  end

  def publish(message) do
    GenServer.call(__MODULE__, {:publish, message})
  end

  def handle_call({:publish, message}, _, %{chan: chan, connected: true, queue_name: queue_name} = state) do
    result = Basic.publish(chan, "", @queue, message, persistent: true)
    {:reply, result, state}
  end

  def handle_info({:DOWN, _, :process, _pid, _reason}, state) do
    new_state = connect(state)
    {:noreply, state}
  end

  def handle_info(:connect, state) do
    new_state = connect(state)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    {:noreply, state}
  end

  def terminate(_reason, %{conn: conn}) do
    Connection.close(conn)
    :ok
  end

  def connect(%{queue_name: queue_name} = state) do
    default_opts = [host: nil, port: nil]

    opts =
      [host: "localhost", port: 1414]
      |> Enum.filter(fn({_, v}) -> v != "" && v != nil end)

   # case Connection.open(Keyword.merge(default_opts, opts)) do
      case Connection.open do
      {:ok, conn} ->
        Process.monitor(conn.pid)

        {:ok, chan} = Channel.open(conn)

        Queue.declare(chan, queue_name, durable: true)
        Exchange.fanout(chan, @exchange, durable: true)
        Queue.bind(chan, queue_name, @exchange)

        %{ state | chan: chan, connected: true, conn: conn }
      {:error, _} ->
        reconnect(state)
        %{state | chan: nil, connected: false, conn: nil }
    end
  end

  defp reconnect(state) do
    Process.send_after(self(), :connect, @reconnect_timeout)
  end

end
