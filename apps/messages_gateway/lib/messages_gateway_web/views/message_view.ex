defmodule MessagesGatewayWeb.MessageView do
  use MessagesGatewayWeb, :view
  def render("index.json", %{:body => body}) do
    body
  end
end