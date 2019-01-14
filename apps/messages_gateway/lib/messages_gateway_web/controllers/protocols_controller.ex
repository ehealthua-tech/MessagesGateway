defmodule MessagesGatewayWeb.ProtocolsController do
  @moduledoc false

  use MessagesGatewayWeb, :controller
  action_fallback(MessagesGatewayWeb.FallbackController)

  def index(conn, _params) do
    with {ok, protocols} <- MessagesGateway.RedisManager.keys("*_protocol")
      do
      render(conn, "protocols.json", %{protocols: protocols})
    end
  end

  def show(conn, %{"id" => name}) do
    with fields <- MessagesGateway.RedisManager.get(name)
      do
      render(conn, "protocols.json", %{fields: Jason.decode!(fields)})
    end
  end

end
