defmodule MessagesGatewayWeb.AdminView do
  use MessagesGatewayWeb, :view
  def render("index.json", %{:body => body}) do
    body
  end
end