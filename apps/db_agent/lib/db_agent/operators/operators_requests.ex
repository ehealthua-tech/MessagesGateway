defmodule DbAgent.OperatorsRequests do
  @moduledoc false
  alias DbAgent.Operators, as: OperatorsSchema
  alias DbAgent.OperatorTypes, as: OperatorTypesSchema
  alias DbAgent.Repo
  alias Ecto.Adapters.SQL

  import Ecto.Query
  import Ecto.Changeset


  @spec list_operators :: [OperatorsSchema.t()] | [] | {:error, Ecto.Changeset.t()}
  def list_operators() do
    OperatorsSchema
    |> join(:inner, [op], opt in OperatorTypesSchema, opt.id == op.operator_type_id)
    |> select([op, opt],%{operator: op, operator_type: opt})
    |> Repo.all()
  end

#  @spec add_operator(params :: OperatorsSchema.t()) :: OperatorsSchema.t() | [] | {:error, Ecto.Changeset.t()}
  def add_operator(params) do
    %OperatorsSchema{}
    |> OperatorsSchema.changeset(params)
    |> Repo.insert()
  end

  def change_operator(id, operator_info) do
    OperatorsSchema
    |> where([ot], ot.id == ^id)
    |> Repo.update_all( set: operator_info)
  end

  def get_by_name(name) do
    OperatorsSchema
    |> where([op], op.name == ^name)
    |> Repo.one!()
  end

  def operator_by_id(id) do
    OperatorsSchema
    |> where([op], op.id == ^id)
    |> Repo.one!()
  end


  def delete(id) do
    from(p in Post, where: p.id == ^id)
    |> Repo.delete()
  end

  def update_priority(operators_info) do
    values = create_query_values(operators_info, "")
    query  = "UPDATE operators as op
      set priority = update.priority, active = update.active
      from ( values "
         <> values <>
      ") update(id, priority, active)
      where update.id = op.id"
    SQL.query(Repo, query)
  end

  defp create_query_values([], acc), do:  binary_part(acc, 1, byte_size(acc) - 1)
  defp create_query_values([%{"id" => id, "priority" => priority, "active" => active}|t], acc) do
    new_acc = Enum.join([acc, ",(uuid('" , id, "'), ", Integer.to_string(priority), ", ", Atom.to_string(active), ")"])
    create_query_values(t, new_acc)
  end

end
