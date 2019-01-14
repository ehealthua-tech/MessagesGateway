defmodule MessagesGatewayWeb.SystemConfigView do
  @moduledoc false
  use MessagesGatewayWeb, :view

  def render("index.json", %{:config => system_config}) do
    system_config
  end

end