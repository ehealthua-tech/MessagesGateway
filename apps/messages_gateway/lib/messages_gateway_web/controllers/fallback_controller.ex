defmodule MessagesGatewayWeb.FallbackController do
  @moduledoc """
  This controller should be used as `action_fallback` in rest of controllers to remove duplicated error handling.
  """

  use MessagesGatewayWeb, :controller

  alias EView.Views.Error
  alias EView.Views.ValidationError

  def call(conn, {:error, {:bad_request, reason}}) when is_binary(reason) do
    conn
    |> put_status(:bad_request)
    |> render(Error, :"400", %{message: reason})
  end

  def call(conn, {:error, :access_denied}) do
    conn
    |> put_status(:unauthorized)
    |> render(Error, :"401", %{message: :access_denied})
  end

  def call(conn, {:error, {:access_denied, reason}}) when is_map(reason) do
    conn
    |> put_status(:unauthorized)
    |> render(Error, :"401", reason)
  end

  def call(conn, {:error, {:access_denied, reason}}) do
    conn
    |> put_status(:unauthorized)
    |> render(Error, :"401", %{message: reason})
  end

  def call(conn, {:error, {:too_many_requests, reason}}) when is_map(reason) do
    conn
    |> put_status(:too_many_requests)
    |> render(Error, :"401", reason)
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> render(Error, :"403", %{message: :forbidden})
  end

  def call(conn, {:error, {:forbidden, reason}}) when is_map(reason) do
    conn
    |> put_status(:forbidden)
    |> render(Error, :"403", reason)
  end

  def call(conn, {:error, {:password_expired, reason}}) do
    conn
    |> put_status(:unauthorized)
    |> render(Error, :"401", %{message: reason, type: :password_expired})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(Error, :"404", %{message: :not_found})
  end

  def call(conn, nil) do
    conn
    |> put_status(:not_found)
    |> render(Error, :"404", %{message: :not_found})
  end

  def call(conn, {:error, {:conflict, reason}}) do
    call(conn, {:conflict, reason})
  end

  def call(conn, {:conflict, reason}) do
    conn
    |> put_status(:conflict)
    |> render(Error, :"409", %{message: reason})
  end

  def call(conn, {:error, {:"422", error}}) do
    conn
    |> put_status(422)
    |> render(Error, :"400", %{message: error})
  end

  def call(conn, {:error, {:unprocessable_entity, error}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(Error, :"400", %{message: error})
  end

  def call(conn, {:error, {:internal_error, reason}}) do
    conn
    |> put_status(:internal_error)
    |> render(Error, :"500", %{message: reason})
  end

  def call(conn, {:error, {:service_unavailable, reason}}) do
    conn
    |> put_status(:service_unavailable)
    |> render(Error, :"503", %{message: reason})
  end

  def call(conn, {:error, :operators_present}) do
    conn
    |> put_status(:conflict)
    |> render(Error, :"400", %{message: "Before deleting an operator type - delete the operators attached to it"})
  end

  def call(conn, _) do
    conn
    |> put_status(:conflict)
    |> render(Error, :"502", %{message: "Internal server error"})
  end

  @doc """
  Proxy response from APIs
  """
  def call(conn, {_, %{"meta" => %{}} = proxy_resp}) do
    Proxy.proxy(conn, proxy_resp)
  end

end