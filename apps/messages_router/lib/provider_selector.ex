defmodule ProviderSelector do
  @moduledoc false

  def send_message(payload) do
    :io.format("Operator selector for:~p~n",[payload])
  end

end
