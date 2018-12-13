defmodule ProviderSelector do
  @moduledoc false

  def send_message(payload) do
    :io.format("Operator selector for:~p~n",[payload])
    [provider | priority_list] = MessagesGateway.Prioritization.get_priority_list()
    if MqSubscriber.publish(payload, provider) do
      GenServer.call(MqSubscriber, {:message_sent, payload})
      else
      [next_provider | new_priority_list] = priority_list
      MqSubscriber.publish(payload, next_provider)
    end
  end

end
