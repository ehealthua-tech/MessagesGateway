defmodule MessagesGatewayWeb.KeysView do
  @moduledoc false
  use MessagesGatewayWeb, :view

  def render("index.json", %{:user => user, :key => key, :status => status}) do
    %{user: user, key: key, status: status}
  end

  def render("change_keys.json", %{:status => status}) do
    %{status: status}
  end

end