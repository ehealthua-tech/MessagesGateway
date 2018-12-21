defmodule MessagesGatewayWeb.SystemConfigView do
  @moduledoc false
  use MessagesGatewayWeb, :view

  def render("index.json", %{}) do
    %{status: :ok}
  end
end