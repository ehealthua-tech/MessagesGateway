defmodule MessagesGatewayWeb.KeysView do
  @moduledoc false
  use MessagesGatewayWeb, :view

  def render("change_keys.json", %{:status => status}) do
    %{status: status}
  end

  def render("keys.json", %{:keys => keys}) do
    %{keys: keys}
  end

end