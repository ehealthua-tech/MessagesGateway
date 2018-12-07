defmodule MessagesGatewayWeb.MessageView do
  @moduledoc false
  use MessagesGatewayWeb, :view

  def render("index.json", %{request_id: request_id, message_id: message_id}) do
    %{
      "id" => request_id,
      "message_id" => message_id,
    }
  end

  def render("message_status.json", %{request_id: request_id, message_id: message_id, message_status: message_status})
    do
    %{
      "id" => request_id,
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