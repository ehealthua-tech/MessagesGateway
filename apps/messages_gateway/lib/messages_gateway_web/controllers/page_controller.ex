defmodule MessagesGatewayWeb.PageController do
  use MessagesGatewayWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
