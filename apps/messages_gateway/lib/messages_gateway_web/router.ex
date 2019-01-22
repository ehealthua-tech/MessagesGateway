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

    post "/system_config", SystemConfigController, :add
    scope "/system_config" do
      resources "/", SystemConfigController, except: [:new, :edit, :update, :create, :delete, :show]
    end
  end

  scope "/sending", MessagesGatewayWeb do
    pipe_through :api
    post "/message", MessageController, :new_message
    post "/email", MessageController, :new_email
    post "/status", MessageController, :message_status
  end

end
