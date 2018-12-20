defmodule ViberApi do

  alias ViberEndpoint

    def send_message(phone, message) do
      params
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.into(%{})
      |> Poison.encode!()

  end

  def add_contact(conn) do
    :io.format("~n~nconn :~p~n", [conn])
    :io.format("~n~nconn :~p~n", [conn.body])
  end


end
