defmodule ViberEndpoint do
  @moduledoc false
  @viber_url "https://chatapi.viber.com/pa"

  def viber_api(), do: @viber_url

  def request(method, body \\ []) do
    newbody = Jason.encode!(body)
    :io.format("~nnewbody: ~p~n", [newbody])
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
         {:ok, %{result: result}} <- Jason.decode(body, keys: :atoms),
         do: {:ok, result}
  end

  defp build_url(method) do
    url = @viber_url <> "/" <> method

    :io.format("~nurl:~p~n", [url])
    url
  end

  defp headers() do
    auth_token = Application.get_env(:viber_protocol, :auth_token)
    header =
      [
        "Content-Type": "application/json",
        "X-Viber-Auth-Token": auth_token
      ]

    :io.format("~nheader: ~p~n", [header])
    header
  end
end
