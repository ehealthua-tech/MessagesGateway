defmodule DbAgent.OperatorTypesRequests do
  @moduledoc false
  alias DbAgent.OperatorTypes, as: OperatorTypesSchema
  alias DbAgent.Operators, as: Operators
    alias DbAgent.Repo
  alias Ecto.Adapters.SQL

  import Ecto.Query
  import Ecto.Changeset

  @spec list_operator_types :: [OperatorTypesSchema.t()] | [] | {:error, Ecto.Changeset.t()}
  def list_operator_types() do
    Repo.all(OperatorTypesSchema)
  end

  @spec add_operator_type(params :: OperatorTypesSchema.operator_types_map()) :: {:ok, OperatorTypesSchema.t()} | {:error, Ecto.Changeset.t()}
  def add_operator_type(params) do
    %OperatorTypesSchema{}
    |> OperatorTypesSchema.changeset(params)
    |> Repo.insert()
  end

  @spec change_status(params :: OperatorTypesSchema.operator_types_map()) :: {integer(), nil | [term()]}
  def change_status(params) do
    OperatorTypesSchema
    |> where([ot], ot.id == ^params.id)
    |> Repo.update_all( set: [active: params.active])
  end

  @spec get_by_name(name :: String.t()) :: Ecto.Schema.t() | nil
  def get_by_name(name) do
    OperatorTypesSchema
    |> where([op], op.name == ^name)
    |> Repo.one!()
  end

  @spec delete(id :: String.t()) :: {integer(), nil | [term()]}
  def delete(id) do
    from(p in OperatorTypesSchema, where: p.id == ^id)
    |> Repo.delete_all()
  end

  @spec update_priority(operators_info :: [map()]) :: {:ok, %{:rows => nil | [[term] | binary], :num_rows => non_neg_integer, optional(atom) => any}} | {:error, Exception.t}
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

  @spec create_query_values([map()], any()) :: binary()
  defp create_query_values([], acc), do:  binary_part(acc, 1, byte_size(acc) - 1)
  defp create_query_values([%{"id" => id, "priority" => priority, "active" => active}|t], acc) do
    new_acc = Enum.join([acc, ",(uuid('" , id, "'), ", Integer.to_string(priority), ", ", Atom.to_string(active), ")"])
    create_query_values(t, new_acc)
  end

end
