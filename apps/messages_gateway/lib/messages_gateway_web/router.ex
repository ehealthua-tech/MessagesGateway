defmodule MessagesGatewayWeb.Router do
  use MessagesGatewayWeb, :router

  pipeline :api do
    plug :accepts, ["json"]

  end

  scope "/api", MessagesGatewayWeb do
    pipe_through :api

    scope "/operator_type"  do
      post "/deactivate", OperatorTypeController, :deactivate
      resources "/", OperatorTypeController, except: [:new, :show, :edit, :update]
      post "/update_priority", OperatorTypeController, :update_priority

    end

    scope "/get_protocol" do
      resources "/", ProtocolsController, except: [:new, :edit, :update, :create, :delete]
    end

    scope "/operators" do
      post "/change", OperatorsController, :change_info
      post "/update_priority", OperatorsController, :update_priority
      resources "/", OperatorsController, except: [:new, :edit, :update]

    end

    scope "/system_config" do
      resources "/", SystemConfigController, except: [:new, :edit, :update, :create, :delete]
    end

    post "/system_config", SystemConfigController, :add
    post "/send_message", MessageController, :new_message
    post "/send_sms", MessageController, :new_sms
    post "/send_email", MessageController, :new_email
    post "/message_status", MessageController, :message_status

  end

end
