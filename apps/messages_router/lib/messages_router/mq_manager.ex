defmodule MessagesRouter.MqManager do
    use GenServer
    use AMQP

    @reconnect_timeout 5000

    @spec start_link() :: {:ok, pid()} | :ignore | {:error, {:already_started, pid()} | term()}
    def start_link do
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    @spec init(term()) :: {:ok, any()} | {:ok, any(), :infinity | non_neg_integer() | :hibernate |
                 {:continue, term()}} | :ignore | {:stop, reason :: any()}
    def init(_opts) do
      queue = Application.get_env(:messages_gateway,  MessagesGateway.MqManager)[:mq_queue]
      state = %{connected: false, chan: nil, queue_name: queue, conn: nil, subscribe: nil}
      {:ok, connect(state)}
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
      config = Application.get_env(:messages_router,  MessagesRouter.MqManager)
      host = config[:mq_host]
      port = String.to_integer(config[:mq_port])
      exchange = Application.get_env(:messages_gateway,  MessagesGateway.MqManager)[:mq_exchange]

      case Connection.open([host: host, port: port]) do
        {:ok, conn} ->
          Process.monitor(conn.pid)
          {:ok, chan} = Channel.open(conn)
          Queue.declare(chan, queue_name, [durable: true, arguments: [{"x-max-priority", :short, 10}]])
          Exchange.fanout(chan, exchange, durable: true)
          Queue.bind(chan, queue_name, exchange)
          {:ok, sub} = AMQP.Queue.subscribe(chan, queue_name,
            fn(payload, _meta) -> MessagesRouter.send_message(Jason.decode!(payload, [keys: :atoms])) end)
          %{ state | chan: chan, connected: true, conn: conn, subscribe: sub }
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
