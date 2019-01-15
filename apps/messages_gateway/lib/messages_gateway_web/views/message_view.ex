defmodule MessagesGatewayWeb.MessageView do
  @moduledoc false
  use MessagesGatewayWeb, :view

  def render("index.json", %{message_id: message_id}) do
    %{
      "message_id" => message_id,
    }
  end

  def render("message_status.json", %{message_id: message_id, message_status: message_status})
    do
    %{
       "message_id" => message_id,
      "message_status" => message_status
    }
  end

  def render("message_change_status.json", _) do
    %{
      message: "Status of sending was successfully changed"
    }
  end
end