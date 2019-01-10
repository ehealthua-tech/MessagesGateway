defmodule DbAgent.OperatorsRequests do
  @moduledoc false
  alias DbAgent.Operators, as: OperatorsSchema
  alias DbAgent.OperatorTypes, as: OperatorTypesSchema
  alias DbAgent.Repo
  alias Ecto.Adapters.SQL

  import Ecto.Query
  import Ecto.Changeset

  @type operator_info_map :: %{
                               id: String.t(),
                               active: boolean,
                               config: map,
                               limit: integer,
                               name:  String.t(),
                               operator_type: map(),
                               price: integer,
                               priority: integer
                             }

  @spec list_operators :: [OperatorsSchema.t()] | [] | {:error, Ecto.Changeset.t()}
  def list_operators() do
    OperatorsSchema
    |> join(:inner, [op], opt in OperatorTypesSchema, opt.id == op.operator_type_id)
    |> select([op, opt],%{operator: op, operator_type: opt})
    |> Repo.all()
  end

  @spec add_operator(params :: OperatorsSchema.operators_map()) :: {:ok, OperatorsSchema.t()} | {:error, Ecto.Changeset.t()}
  def add_operator(params) do
    %OperatorsSchema{}
    |> OperatorsSchema.changeset(params)
    |> Repo.insert()
  end

  @spec change_operator(id :: String.t(), operator_info :: operator_info_map()) :: {integer(), nil | [term()]}
  def change_operator(id, operator_info) do
    OperatorsSchema
    |> where([ot], ot.id == ^id)
    |> Repo.update_all( set: operator_info)
  end

  @spec get_by_name(name :: String.t()) :: Ecto.Schema.t() | nil
  def get_by_name(name) do
    OperatorsSchema
    |> where([op], op.name == ^name)
    |> Repo.one!()
  end

  @spec operator_by_id(id :: String.t()) :: Ecto.Schema.t() | nil
  def operator_by_id(id) do
    OperatorsSchema
    |> where([op], op.id == ^id)
    |> Repo.one!()
  end

  @spec operator_by_operator_type_id(operator_type_id :: String.t()) :: [Ecto.Schema.t()]
  def operator_by_operator_type_id(operator_type_id) do
    OperatorsSchema
    |> where([op], op.operator_type_id == ^operator_type_id)
    |> Repo.all()
  end

  @spec delete(id :: String.t()) :: {integer(), nil | [term()]}
  def delete(id) do
    from(p in OperatorsSchema, where: p.id == ^id)
    |> Repo.delete_all()
  end

  @spec update_priority(operators_info :: [operator_info_map()]) :: {:ok, %{:rows => nil | [[term] | binary], :num_rows => non_neg_integer, optional(atom) => any}} | {:error, Exception.t}
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

  @spec create_query_values([operator_info_map()], String.t()) :: binary()
  defp create_query_values([], acc), do:  binary_part(acc, 1, byte_size(acc) - 1)
  defp create_query_values([%{"id" => id, "priority" => priority, "active" => active}|t], acc) do
    new_acc = Enum.join([acc, ",(uuid('" , id, "'), ", Integer.to_string(priority), ", ", Atom.to_string(active), ")"])
    create_query_values(t, new_acc)
  end

end
