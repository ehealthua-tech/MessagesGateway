defmodule MessagesGateway.MqManager do
  use GenServer
  use AMQP

  @reconnect_timeout 5000
  @exchange    "message_exchange"
  @queue       "message_queue"

  @spec start_link() :: {:ok, pid()} | :ignore | {:error, {:already_started, pid()} | term()}
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(term()) :: {:ok, any()} | {:ok, any(), :infinity | non_neg_integer() | :hibernate |
                                                                                    {:continue, term()}} | :ignore | {:stop, reason :: any()}
  def init(_opts) do
    state = %{connected: false, chan: nil, queue_name: @queue, conn: nil, subscribe: nil}
    {:ok, connect(state)}
  end

  @spec publish(String.t()) :: term()
  def publish(message) do
    GenServer.call(__MODULE__, {:publish, message})
  end

  @spec handle_call(term(), {pid(), tag :: term()}, state :: term()) ::
          {:reply, reply, new_state}
          | {:reply, reply, new_state, timeout() | :hibernate | :infinity | non_neg_integer() | {:continue, term()}}
          | {:noreply, new_state}
            | {:noreply, new_state, timeout() | :hibernate | timeout(), {:continue, term()}}
            | {:stop, reason, reply, new_state}
              | {:stop, reason, new_state}
        when reply: term(), new_state: term(), reason: term()
  def handle_call({:publish, message}, _, %{chan: chan, connected: true, queue_name: queue_name} = state) do
    result = Basic.publish(chan, "", @queue, message, [persistent: true, priority: 0])
    message_id = Map.get(Jason.decode!(message), "message_id")
    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{:message_id => "message_id", status: "add_to_queue"}})
    {:reply, result, state}
  end

  def handle_call(:queue_size, _, %{chan: chan, queue_name: queue_name} = state) do
    queue_size = AMQP.Queue.message_count(chan, queue_name)
    {:reply, {:ok, queue_size, DateTime.to_string(DateTime.utc_now())}, state}
  end

  @spec handle_info(msg :: :timeout | term(), state :: term()) ::
          {:noreply, new_state}
          | {:noreply, new_state, timeout() | :hibernate | {:continue, term()}}
          | {:stop, reason :: term(), new_state}
        when new_state: term()
  def handle_info(:message, state) do
    new_state = connect(state)
    {:noreply, new_state}
  end

  def handle_info({:DOWN, _, :process, _pid, _reason}, state) do
    new_state = connect(state)
    {:noreply, new_state}
  end

  def handle_info(:connect, state) do
    new_state = connect(state)
    {:noreply, new_state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  @spec terminate(reason, state :: term()) :: term()
        when reason: :normal | :shutdown | {:shutdown, term()}
  def terminate(_reason, %{conn: conn, subscribe: sub, chan: chan} = state) do
    Queue.unsubscribe(chan, sub)
    Connection.close(conn)
    state
  end

  @spec connect(map()) :: map()
  def connect(%{queue_name: queue_name} = state) do
    config = Application.get_env(:messages_gateway,  MessagesGateway.MqManager)
    host = config[:mq_host]
    port = config[:mq_port]

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

  @spec reconnect(map()) :: reference()
  defp reconnect(_state) do
    Process.send_after(self(), :connect, @reconnect_timeout)
  end

end

