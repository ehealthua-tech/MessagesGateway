defmodule SmtpProtocol do
  def send_email(recipient, subject, body) do
    SmtpProtocol.Email.email(recipient, subject, body) |> SmtpProtocol.Mailer.deliver_now
  end
end
