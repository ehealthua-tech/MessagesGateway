defmodule DbAgent.OperatorTypesRequests do
  @moduledoc false
  alias DbAgent.OperatorTypes, as: OperatorTypesSchema
  alias DbAgent.Operators, as: Operators
  alias DbAgent.Repo
  alias Ecto.Adapters.SQL

  import Ecto.Query
  import Ecto.Changeset

  @typep operator_info_map :: %{
                               id: String.t(),
                               active: boolean,
                               config: map,
                               limit: integer,
                               name:  String.t(),
                               operator_type: map(),
                               price: integer,
                               priority: integer
                             }

  @typep operator_types_map :: %{
                                 active: boolean,
                                 name:  String.t(),
                                 priority: integer
                                }

  @typep operator_types_map_req :: %{
                                     id: String.t(),
                                     active: boolean,
                                     name:  String.t(),
                                     priority: integer
                                   }

  @doc """
    Get all operator types from database
  """
  @spec list_operator_types() :: result when
          result: [OperatorTypesSchema.t()] | [] | {:error, Ecto.Changeset.t()}

  def list_operator_types() do
    Repo.all(OperatorTypesSchema)
  end

  @doc """
    Add operator type to database
  """
  @spec add_operator_type(params) :: result when
          params: operator_types_map(),
          result: {:ok, OperatorTypesSchema.t()} | {:error, Ecto.Changeset.t()}

  def add_operator_type(params) do
    priority = calc_priority()
    insert_params = Map.put(params, :priority, priority)
    %OperatorTypesSchema{}
    |> OperatorTypesSchema.changeset(insert_params)
    |> Repo.insert()
  end

  @doc """
    Change operator type status
  """
  @spec change_status(param) :: result when
          param: %{id: String.t(), active: boolean()},
          result: {integer(), nil | [term()]}

  def change_status(params) do
    OperatorTypesSchema
    |> where([ot], ot.id == ^params.id)
    |> Repo.update_all( set: [active: params.active])
  end

  @doc """
    Get operator type by name
  """
  @spec get_by_name(name) :: result when
          name: String.t(),
          result: Ecto.Schema.t() | nil

  def get_by_name(name) do
    OperatorTypesSchema
    |> where([op], op.name == ^name)
    |> Repo.one!()
  end

  @doc """
    Delete operator type by name
  """
  @spec delete(id) :: result when
          id: String.t(),
          result: {integer(), nil | [term()]}

  def delete(id) do
    from(p in OperatorTypesSchema, where: p.id == ^id)
    |> Repo.delete_all()
  end

  @doc """
    Change operator type priority
  """
  @spec update_priority(operators_info) :: result when
          operators_info: [operator_info_map()],
          result: {:ok, %{:rows => nil | [[term] | binary], :num_rows => non_neg_integer, optional(atom) => any}} | {:error, Exception.t}

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

  @doc """
    Create database query
  """
  @spec create_query_values(operators_info, query) :: result when
          operators_info: [operator_info_map()],
          query: String.t(),
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

  defp calc_priority(max_priority) when is_integer(max_priority), do: max_priority + 1
  defp calc_priority(_), do: 1

  defp select_max_priority() do
    query = from ot in OperatorTypesSchema, select: max(ot.priority)
    SQL.query(Repo, query)
  end
end
