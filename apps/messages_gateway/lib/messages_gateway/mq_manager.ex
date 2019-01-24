defmodule MessagesGateway.MqManager do
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
    :io.format("~nmessage: ~p~n", [message])
    result = Basic.publish(chan, "", @queue, message, [persistent: true, priority: 0])
    :io.format("~nresult: ~p~n", [result])
    {:reply, result, state}
  end

  def handle_call(:queue_size, _, %{chan: chan, queue_name: queue_name} = state) do
    queue_size = AMQP.Queue.message_count(chan, queue_name)
    {:reply, {:ok, queue_size}, state}
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
    host = Application.get_env(:messages_gateway, :mq_host, "localhost")
    port = Application.get_env(:messages_gateway, :mq_port, 5672)

    case Connection.open([host: host, port: port]) do
      {:ok, conn} ->
        Process.monitor(conn.pid)

        {:ok, chan} = Channel.open(conn)

        Queue.declare(chan, queue_name, [durable: true, arguments: [{"x-max-priority", :short, 10}]])
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
