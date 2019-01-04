defmodule SmtpProtocol do
  def hello do
    SmtpProtocol.Email.welcome_email |> SmtpProtocol.Mailer.deliver_now
  end
end
