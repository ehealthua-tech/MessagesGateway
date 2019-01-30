defmodule SmtpProtocol do
  use GenServer
  alias SmtpProtocol.RedisManager

  @protocol_config   %{
    active: true,
    active_protocol_type: true,
    configs: %{},
    limit: 10,
    operator_priority: 1,
    priority: 2,
    protocol_name: "smtp_protocol"
  }


  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, app_name} = :application.get_application(__MODULE__)
    RedisManager.set(Atom.to_string(app_name), @protocol_config)
    MgLogger.log_message(__MODULE__, %{__MODULE__ => "started"})
    {:ok, []}
  end

  def send_email(%{message_id: message_id, contact: recipient, body: body, subject: subject}) do
    SmtpProtocol.Email.email(recipient, subject, body) |> SmtpProtocol.Mailer.deliver_now
    MgLogger.log_message(__MODULE__, %{"message_id" => message_id, "status" => "sent"})
  end
end
