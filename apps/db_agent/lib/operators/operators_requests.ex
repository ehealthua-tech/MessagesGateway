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
    priority = calc_priority(params)
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
  defp create_query_values([%{id: id, priority: priority, active: active}|t], acc) do
    new_acc = Enum.join([acc, ",(uuid('" , id, "'), ", Integer.to_string(priority), ", ", Atom.to_string(active), ")"])
    create_query_values(t, new_acc)
  end

  def calc_priority(%{"name" => name, "price" => price}) do
      select_operators_as_list_of_maps()
      |> calc_priority_on_price(%{name: name, price: price})
  end

  defp calc_priority_on_price([], operator_for_adding), do: 1
  defp calc_priority_on_price(operators_as_list_of_maps, operator_for_adding) do
    sort_list =
      [operator_for_adding | operators_as_list_of_maps]
      |> Enum.sort_by(&{&1.price, String.downcase(&1.name)})

    operators_for_update = List.delete(sort_list, operator_for_adding)
    Enum.map(operators_for_update, fn(x)-> Map.put(x, :priority, Enum.find_index(sort_list,  fn(y) -> if Map.has_key?(y, :id) do y.id == x.id end end) + 1 ) end)
    |> check_and_update_priority(operators_as_list_of_maps)

    Enum.find_index(sort_list,  fn(x) -> Map.has_key?(x, :id) == false end) + 1
  end

#  defp calc_priority_on_price(operators_as_list_of_maps), do: ok
  defp calc_priority_on_price() do
    operators_as_list_of_maps = select_operators_as_list_of_maps
    sort_list = Enum.sort_by(operators_as_list_of_maps, &{&1.price, String.downcase(&1.name)})
    Enum.map(sort_list, fn(x)-> Map.put(x, :priority, Enum.find_index(sort_list,  fn(y) -> y.id == x.id end) + 1 ) end)
    |> check_and_update_priority(operators_as_list_of_maps)
  end


  defp check_and_update_priority(operators_new, operators_old) when operators_new == operators_old,  do: :ok
  defp check_and_update_priority(operators_new, operators_old), do: update_priority(operators_new)

  defp select_operators_as_list_of_maps() do
    query = from operators in OperatorsSchema, select: %{price: operators.price,
      priority: operators.priority,
      name: operators.name,
      id: operators.id,
      active: operators.active}
    Repo.all(query)
  end

end
