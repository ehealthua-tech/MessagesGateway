defmodule LifecellIpTelephonyProtocol.MqManager do
    use GenServer
    use AMQP

    @reconnect_timeout 5000
    @exchange    "message_exchange"
    @queue_name  "sms"

    def start_link do
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def init(_opts) do
      {:ok, app_name} = :application.get_application(__MODULE__)
      :io.format("~napp_name: ~p~n", [app_name])
      state = %{connected: false, chan: nil, queue_name: to_string(app_name), conn: nil, subscribe: nil}
      {:ok, connect(state)}
    end

    def publish(message, priority) do
      GenServer.call(__MODULE__, {:publish, message, priority})
    end

    def handle_call({:publish, message, priority}, _, %{chan: chan, connected: true, queue_name: queue_name} = state) do
      queue_name = DbAgent.OperatorTypesRequests.get_by_name(@queue_name)
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
      host = Application.get_env(:sms_router, :mq_host, "localhost")
      port = Application.get_env(:sms_router, :mq_port, 5672)

      case Connection.open([host: host, port: port]) do
        {:ok, conn} ->
          Process.monitor(conn.pid)
          {:ok, chan} = Channel.open(conn)
          Queue.declare(chan, queue_name, [durable: true, arguments: [{"x-max-priority", :short, 10}]])
          Exchange.fanout(chan, @exchange, durable: true)
          Queue.bind(chan, queue_name, @exchange)
          {ok, sub} = AMQP.Queue.subscribe chan, queue_name,
            fn(payload, _meta) -> Jason.decode!(payload, :atoms) |> LifecellIpTelephonyProtocol.send_message() end
          %{ state | chan: chan, connected: true, conn: conn, subscribe: sub }
        {:error, _} ->
          reconnect(state)
          %{state | chan: nil, connected: false, conn: nil }
      end
    end

    defp reconnect(state) do
      Process.send_after(self(), :connect, @reconnect_timeout)
    end

    def send_to_operator(message, operator_queue) do
      GenServer.call(__MODULE__, {:send_to_operator, message, operator_queue})
    end

  end
