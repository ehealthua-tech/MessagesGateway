defmodule DbAgent.OperatorTypesRequests do
  @moduledoc false
  alias DbAgent.OperatorTypes, as: OperatorTypesSchema
  alias DbAgent.Repo

  import Ecto.Query
  import Ecto.Changeset

  @spec list_operator_types :: [OperatorTypesSchema.t()] | [] | {:error, Ecto.Changeset.t()}
  def list_operator_types() do
    Repo.all(OperatorTypesSchema)
  end

  @spec add_operator_type(params :: Keyword.t()) :: OperatorTypesSchema.t() | [] | {:error, Ecto.Changeset.t()}
  def add_operator_type(params) do
    %OperatorTypesSchema{}
    |> OperatorTypesSchema.changeset(params)
    |> Repo.insert()
  end

  @spec change_status(params :: Keyword.t()) :: {:ok, OperatorTypesSchema.t()} | {:error, Ecto.Changeset.t()}
  def change_status(params) do
    OperatorTypesSchema
    |> where([ot], ot.id == ^params.id)
    |> Repo.update_all( set: [active: params.active])
  end

end
