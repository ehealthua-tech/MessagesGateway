defmodule SmtpProtocol.Email do
  import Bamboo.Email

  def email(recipient, subject, body) do
    new_email(
      to: recipient,
      from: "",
      subject: subject,
      html_body: Enum.join(["<strong>",body, "</strong>"]),
      text_body: body
    )

  end
end