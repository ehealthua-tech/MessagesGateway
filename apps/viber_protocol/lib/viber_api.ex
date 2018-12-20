defmodule ViberApi do

  alias ViberEndpoint

    def send_message(phone, message) do
      message
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.into(%{})
      :ok

  end

  def add_contact(conn) do
    :io.format("~n~nconn :~p~n", [conn])
    :io.format("~n~nconn :~p~n", [conn.body_params])
  end


end
