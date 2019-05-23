defmodule MessagesGatewayWeb.Router do
  use MessagesGatewayWeb, :router

  use Plug.ErrorHandler

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug(:required_headers)
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
      resources "/", OperatorsController, except: [:new, :edit, :update]

    end

    post "/system_config", SystemConfigController, :add
    scope "/system_config" do
      resources "/", SystemConfigController, except: [:new, :edit, :update, :create, :delete, :show]
    end

    scope "/keys" do
      post "/deactivate", KeysController, :deactivate
      post "/activate", KeysController, :activate
      get "/all", KeysController, :get_all
      resources "/", KeysController, except: [:new, :edit, :update, :create]
    end
  end

  scope "/sending", MessagesGatewayWeb do
    pipe_through([:api, :auth])
    post "/message", MessageController, :new_message
    post "/email", MessageController, :new_email
    get "/status", MessageController, :message_status
    get "/queue_size", MessageController, :queue_size
    post "/change_message_status", MessageController, :change_message_status
  end

  defp handle_errors(%Plug.Conn{status: 500} = conn, %{kind: kind, reason: reason, stack: stacktrace}) do
     send_resp(conn, 500, Jason.encode!(%{errors: %{detail: "Internal server error"}}))
  end

  defp handle_errors(_, _), do: nil

end
