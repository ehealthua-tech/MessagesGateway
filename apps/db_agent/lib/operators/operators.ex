defmodule DbAgent.Operators do
  @moduledoc """
    Operators schema description
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias DbAgent.OperatorTypes

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
               id: String.t() | nil,
               name: String.t() | nil,
               config:  map | nil,
               priority: integer | nil,
               price: integer | nil,
               limit:  integer | nil,
               protocol_name: String.t() | nil,
               active: boolean | nil,
               inserted_at: NaiveDateTime.t()| nil,
               updated_at: NaiveDateTime.t() | nil
             }

  @type operators_map :: %{
                                id: String.t(),
                                name: String.t(),
                                config:  map,
                                priority: integer,
                                price: integer,
                                limit:  integer,
                                protocol_name: String.t(),
                                active: boolean
                              }


  schema "operators" do
    field(:name, :string, null: false)
    field(:config, :map)
    field(:priority, :integer)
    field(:price, :integer,  default: 0, null: 0)
    field(:limit, :integer)
    field(:protocol_name, :string, null: false)
    field(:active, :boolean, default: false)

    belongs_to(:operator_types, OperatorTypes, foreign_key: :operator_type_id, type: :binary_id)

    timestamps()
  end

  @spec changeset(operators, attrs) :: result when
          operators: t(),
          attrs: map(),
          result: Ecto.Changeset.t()

  def changeset(operators, attrs) do
    operators
    |> cast(attrs, [:name, :operator_type_id, :config, :priority, :price, :limit, :protocol_name, :active])
    |> validate_required([:name, :operator_type_id, :config, :priority, :price, :limit, :protocol_name, :active])
    |> unique_constraint(:name)
    |> foreign_key_constraint(:operator_type_id)
  end
end
