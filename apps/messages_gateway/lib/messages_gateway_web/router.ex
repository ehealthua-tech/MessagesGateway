defmodule MessagesGatewayWeb.Router do
  use MessagesGatewayWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]

  end

  scope "/", MessagesGatewayWeb do
    pipe_through :browser # Use the default browser stack

   # get "/", PageController, :index
    get "/get_system_config", AdminController, :get_system_config
    get "/get_operator_types", AdminController, :get_operator_types
    get "/get_all_operators", AdminController, :get_all_operators

  end

  scope "/", MessagesGatewayWeb do
    pipe_through(:api)

    post "/add_operator", AdminController, :add_operator
    post "/add_system_config", AdminController, :add_system_config
    post "/edit_system_config", AdminController, :edit_system_config
    post "/add_operator_type", AdminController, :add_operator_type
    post "/delete_operator_type", AdminController, :delete_operator_type
    post "/add_operator", AdminController, :add_operator
    post "/operator_edit", AdminController, :operator_edit
    post "/operator_delete", AdminController, :operator_delete

    post "/send_message", MessageController, :send_message
    post "/send_sms", MessageController, :send_sms
    post "/send_email", MessageController, :send_email
    post "/message_status", MessageController, :message_status

  end


  # Other scopes may use custom stacks.
  # scope "/api", MessagesGatewayWeb do
  #   pipe_through :api
  # end
end
