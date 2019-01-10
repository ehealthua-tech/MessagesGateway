defmodule DbAgent.Repo do
  use Ecto.Repo, otp_app: :db_agent

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  @spec init(:supervisor | :runtime, config :: Keyword.t()) :: {:ok, Keyword.t()} | :ignore
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end
