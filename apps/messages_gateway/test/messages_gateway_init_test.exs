defmodule MessagesGatewayInitTest do
  use ExUnit.Case
  use DbAgent.DataCase

  test "app test" do
    MessagesGatewayInit.start_link()
    MessagesGatewayInit.init(nil)
  end

end
