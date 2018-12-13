defmodule DbAgent.OperatorsRequests do
  @moduledoc false
  alias DbAgent.Operators, as: OperatorsSchema
  alias DbAgent.OperatorTypes, as: OperatorTypesSchema
  alias DbAgent.Repo

  import Ecto.Query
  import Ecto.Changeset

  @spec list_operators :: [OperatorsSchema.t()] | [] | {:error, Ecto.Changeset.t()}
  def list_operators() do
    OperatorsSchema
    |> join(:inner, [op], opt in OperatorTypesSchema, opt.id == op.operator_type_id)
    |> select([op, opt],%{operator: op, operator_type: opt})
    |> Repo.all()
  end

  @spec add_operator(params :: Keyword.t()) :: OperatorsSchema.t() | [] | {:error, Ecto.Changeset.t()}
  def add_operator(params) do
    %OperatorsSchema{}
    |> OperatorsSchema.changeset(params)
    |> Repo.insert()
  end

  def change_operator(operator_info) do
    with updates <-
       get_by_id!(Map.get(operator_info, "id"))
       |> change(operator_info)
      do
      Repo.update(updates)
    end
  end

  def delete(id) do
    get_by_id!(id)
    |> Repo.delete()
  end

  def get_by_id!(id) do
    OperatorsSchema
    |> where([op], op.id == ^id)
    |> Repo.one!()
  end
end
