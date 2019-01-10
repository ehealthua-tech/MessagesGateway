defmodule DbAgent.Application do
  @moduledoc """
  The DbAgent Application Service.

  The db_agent system business domain lives in this application.

  Exposes API to clients such as the `DbAgentWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  @spec start(atom(), :permanent | :transient | :temporary) :: {:ok, pid()} | {:ok, pid(), any()} | {:error, term()}
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      supervisor(DbAgent.Repo, []),
    ], strategy: :one_for_one, name: DbAgent.Supervisor)
  end
end
