defmodule TestEndpoint do
  def request(_,_) do
    {:ok, %{status_message: "ok", message_token: "123"}}
  end
end
