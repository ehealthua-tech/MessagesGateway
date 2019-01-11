defmodule LifecellIpTelephonyProtocol do
  @moduledoc """
  Documentation for LifecellIpTelephonyProtocol.
  """

  use SpeakEx.CallController

  def send_message(%{phone: phone, message: message} = payload) do

  end

  def run(call) do
    call
    |> answer!
    |> say(welcome)
    |> hangup!
    |> terminate!
  end
end
