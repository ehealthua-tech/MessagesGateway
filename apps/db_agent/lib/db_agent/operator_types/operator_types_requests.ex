defmodule DbAgent.OperatorTypesRequests do
  @moduledoc false
  alias DbAgent.OperatorTypes, as: OperatorTypesSchema
  alias DbAgent.Repo
  alias Ecto.Adapters.SQL

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

  @spec get_by_name(name :: String.t()) :: {:ok, OperatorTypesSchema.t()} | {:error, Ecto.Changeset.t()}
  def get_by_name(name) do
    OperatorTypesSchema
    |> where([op], op.name == ^name)
    |> Repo.one!()
  end

  def update_priority(operators_info) do
    values = create_query_values(operators_info, "")
    query  = "UPDATE operator_types as opt
      set priority = update.priority, active = update.active
      from ( values "
    <> values <>
       ") update(id, priority, active)
      where update.id = opt.id"
    SQL.query(Repo, query)
  end

  defp create_query_values([], acc), do:  binary_part(acc, 1, byte_size(acc) - 1)
  defp create_query_values([%{"id" => id, "priority" => priority, "active" => active}|t], acc) do
    new_acc = Enum.join([acc, ",(uuid('" , id, "'), ", Integer.to_string(priority), ", ", Atom.to_string(active), ")"])
    create_query_values(t, new_acc)
  end

end
