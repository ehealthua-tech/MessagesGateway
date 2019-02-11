defmodule SmtpProtocol do
  use GenServer
  alias SmtpProtocol.RedisManager

  @protocol_config   %{
    module_name: __MODULE__,
    method_name: :send_email
  }


  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.get(Atom.to_string(app_name))
    |> check_config()
    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{__MODULE__ => "started"}})
    {:ok, []}
  end

  defp check_config({:error, _}) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.set(Atom.to_string(app_name), @protocol_config)
  end

  defp check_config(protocol_config), do: :ok

  def send_email(%{message_id: message_id, contact: recipient, body: body, subject: subject} = all) do
    :io.format("~nEMAIL~n~p~n",[all])
    SmtpProtocol.Email.email(recipient, subject, body) |> SmtpProtocol.Mailer.deliver_now
    GenServer.cast(MgLogger.Server, {:log, __MODULE__, %{:message_id => message_id, status: "sending_smtp"}})
    message_status_info =
      RedisManager.get(message_id)
      |> Map.put(:sending_status, true)
    RedisManager.set(message_id, message_status_info)
    apply(:'Elixir.MessagesRouter', :send_message, [%{message_id: message_id}])
  end
end
