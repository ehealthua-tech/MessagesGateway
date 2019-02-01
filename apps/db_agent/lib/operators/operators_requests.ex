defmodule DbAgent.OperatorsRequests do
  @moduledoc """
    Database requests for contacts
  """

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

  @type operator_info_list :: [
                               id: String.t(),
                               active: boolean,
                               config: map,
                               limit: integer,
                               name:  String.t(),
                               operator_type: map(),
                               price: integer,
                               priority: integer
                             ]
  @type operators_list() :: %{operator: OperatorsSchema.t(), operator_type: OperatorTypesSchema.t() }

  @doc """
    Get all operators from database
  """
  @spec list_operators() :: result when
          result: [operators_list()] | [] | {:error, Ecto.Changeset.t()}

  def list_operators() do
    OperatorsSchema
    |> join(:inner, [op], opt in OperatorTypesSchema, opt.id == op.operator_type_id)
    |> select([op, opt],%{operator: op, operator_type: opt})
    |> Repo.all()
  end

  @doc """
    Add operator to database
  """
  @spec add_operator(params) :: result when
          params: OperatorsSchema.operators_map(),
          result: {:ok, OperatorsSchema.t()} | {:error, Ecto.Changeset.t()}

  def add_operator(params) do
    priority = calc_priority()
    insert_params = Map.put(params, "priority", priority)
    %OperatorsSchema{}
    |> OperatorsSchema.changeset(insert_params)
    |> Repo.insert()
  end

  @doc """
    Change operator data
  """
  @spec change_operator(id, operator_info) :: result when
        id: String.t(),
        operator_info: operator_info_list(),
        result:  {integer(), nil | [term()]}

  def change_operator(id, operator_info) do
    OperatorsSchema
    |> where([ot], ot.id == ^id)
    |> Repo.update_all( set: operator_info)
  end

  @doc """
    Get operator by name
  """
  @spec get_by_name(name) :: result when
          name: String.t(),
          result: Ecto.Schema.t() | nil

  def get_by_name(name) do
    OperatorsSchema
    |> where([op], op.name == ^name)
    |> Repo.one!()
  end

  @doc """
    Get operator by id
  """
  @spec operator_by_id(id) :: result when
          id: String.t(),
          result: Ecto.Schema.t() | nil

  def operator_by_id(id) do
    OperatorsSchema
    |> where([op], op.id == ^id)
    |> Repo.one!()
  end

  @doc """
    Get operator by operator type id
  """
  @spec operator_by_operator_type_id(operator_type_id) :: result when
          operator_type_id: String.t(),
          result: [Ecto.Schema.t()]

  def operator_by_operator_type_id(operator_type_id) do
    OperatorsSchema
    |> where([op], op.operator_type_id == ^operator_type_id)
    |> Repo.all()
  end

  @doc """
    Delete operator by id
  """
  @spec delete(id) :: result when
          id: String.t(),
          result: {integer(), nil | [term()]}

  def delete(id) do
    from(p in OperatorsSchema, where: p.id == ^id)
    |> Repo.delete_all()
  end

  @doc """
    Change operator priority
  """
  @spec update_priority(operators_info) :: result when
          operators_info: [operator_info_map()],
          result:  {:ok, %{:rows => nil | [[term] | binary], :num_rows => non_neg_integer, optional(atom) => any}} | {:error, Exception.t}

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

  @doc """
    Create database query
  """
  @spec create_query_values(operators_info, query) :: result when
          operators_info: [operator_info_map()],
          query:  String.t(),
          result: binary()

  defp create_query_values([], acc), do:  binary_part(acc, 1, byte_size(acc) - 1)
  defp create_query_values([%{"id" => id, "priority" => priority, "active" => active}|t], acc) do
    new_acc = Enum.join([acc, ",(uuid('" , id, "'), ", Integer.to_string(priority), ", ", Atom.to_string(active), ")"])
    create_query_values(t, new_acc)
  end

  defp calc_priority() do
    select_max_priority()
    |> calc_priority()
  end

  defp calc_priority([max_priority]) when is_integer(max_priority), do: max_priority + 1
  defp calc_priority(_), do: 1

  defp select_max_priority() do
    query = from ot in OperatorTypesSchema, select: max(ot.priority)
    Repo.all(query)
  end

end
