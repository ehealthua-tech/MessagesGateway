defmodule TelegramSubscriber do
    use GenServer
    use AMQP

    @reconnect_timeout 5000
    @exchange    "message_exchange"

    def start_link do
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def init(_opts) do
      queue_name = DbAgent.OperatorsRequests.get_by_name("telegram")
      state = %{connected: false, chan: nil, queue_name: queue_name.id, conn: nil, subscribe: nil}
      {:ok, connect(state)}
    end

    def publish(message, priority) do
      GenServer.call(__MODULE__, {:publish, message, priority})
    end

    def send_to_operator(message, operator_queue) do
      GenServer.call(__MODULE__, {:send_to_operator, message, operator_queue})
    end

    def handle_call({:publish, message, priority}, _, %{chan: chan, connected: true, queue_name: queue_name} = state) do
      queue_name = DbAgent.OperatorsRequests.get_by_name("telegram")
      result = Basic.publish(chan, "", queue_name.id, message, [persistent: true, priority: priority])
      {:reply, result, state}
    end

    def handle_call({:send_to_operator, message, operator_queue}, _, %{chan: chan, connected: true, queue_name: queue_name} = state) do
      result = Basic.publish(chan, "", operator_queue, message, [persistent: true, priority: 1])
      {:reply, result, state}
    end

    def handle_info(:message, state) do
      new_state = connect(state)
      {:noreply, state}
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

    def terminate(_reason, %{conn: conn, subscribe: sub, chan: chan} = state) do
      Queue.unsubscribe(chan, sub)
      Connection.close(conn)
      state
    end

    def connect(%{queue_name: queue_name} = state) do
      host = Application.get_env(:telegram_protocol, :mq_host, "localhost")
      port = Application.get_env(:telegram_protocol, :mq_port, 5672)

      case Connection.open([host: host, port: port]) do
        {:ok, conn} ->
          Process.monitor(conn.pid)
          {:ok, chan} = Channel.open(conn)
          Queue.declare(chan, queue_name, [durable: true, arguments: [{"x-max-priority", :short, 10}]])
          Exchange.fanout(chan, @exchange, durable: true)
          Queue.bind(chan, queue_name, @exchange)
          {ok, sub} = AMQP.Queue.subscribe chan, queue_name,
                                           fn(payload, _meta) ->
                                             :io.format("~nPayload:~p~n",[payload])
                                             decoded_payload = Jason.decode!(payload, keys: :atoms)
                                             TelegramApi.send_message(decoded_payload)
                                           end
          :io.format("~nSUB TELEGRAM~n")
          %{ state | chan: chan, connected: true, conn: conn, subscribe: sub }
        {:error, _} ->
          reconnect(state)
          %{state | chan: nil, connected: false, conn: nil }
      end
    end

    defp reconnect(state) do
      Process.send_after(self(), :connect, @reconnect_timeout)
    end

  end
