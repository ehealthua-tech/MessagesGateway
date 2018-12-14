defmodule MessagesGatewayWeb.Router do
  use MessagesGatewayWeb, :router

  pipeline :api do
    plug :accepts, ["json"]

  end

  scope "/", MessagesGatewayWeb do
    pipe_through :api

    scope "/operator_type"  do
      post "/deactivate", OperatorTypeController, :deactivate
      resources "", OperatorTypeController, except: [:new, :delete, :show, :edit, :update]

    end

    scope "/operators" do
      post "/change", OperatorsController, :change_info
      post "/update_priority", OperatorsController, :update_priority
      resources "", OperatorsController, except: [:new, :edit, :update]


    end

#    post "/send_message", MessageController, :send_message
#    post "/send_sms", MessageController, :send_sms
#    post "/send_email", MessageController, :send_email
#    post "/message_status", MessageController, :message_status

  end

end
