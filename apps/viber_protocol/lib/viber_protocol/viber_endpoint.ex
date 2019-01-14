defmodule ViberEndpoint do
  @moduledoc false
  @viber_url "https://chatapi.viber.com/pa"

  def viber_api(), do: @viber_url

  def request(method, body \\ []) do
    newbody = Jason.encode!(body)
    method
    |> build_url()
    |> HTTPoison.post(newbody, headers())
    |> response()
  end

  defp response(response) do
    case decode_response(response) do
      {:ok, result} ->
        {:ok, result}

      {:error, _} = error ->
        error
    end
  end

  defp decode_response(response) do
    with {:ok, %HTTPoison.Response{body: body}} <- response,
         {:ok, %{result: result}} <- Jason.decode(body, [{:keys, :atoms}] )
         do
      {:ok, result}
    end
  end

  defp build_url(method) do
    @viber_url <> "/" <> method
  end

  defp headers() do
    auth_token = Application.get_env(:viber_protocol, :auth_token)
    header =
      [
        "Content-Type": "application/json",
        "X-Viber-Auth-Token": auth_token
      ]
    header
  end
end
