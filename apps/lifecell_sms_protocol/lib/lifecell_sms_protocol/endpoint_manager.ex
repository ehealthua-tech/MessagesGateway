defmodule LifecellSmsProtocol.EndpointManager do
  @moduledoc false

  @send_sms :send_sms
  def prepare_and_send_sms_request(body) do
    headers = create_request_headers()
    :io.format("~nbody~p~n", [body])
    Application.get_env(:lifecell_sms_protocol, :sms_send_url)
    |>  HTTPoison.post(body, headers)
    |> response_validation()

  end


  def response_validation( {:ok, %HTTPoison.Response{status_code: 200, body: body}}), do: {:ok, body}
  def response_validation( {:ok, %HTTPoison.Response{status_code: 404}}), do: {:error, :not_found}
  def response_validation( {:error, %HTTPoison.Error{reason: reason}}), do: {:error, :reason}


  def create_request_headers() do
    login = Application.get_env(:lifecell_sms_protocol, :login)
    password = Application.get_env(:lifecell_sms_protocol, :password)
    ["Authorization": Base.encode64(login <>":"<> password)]
  end
end
