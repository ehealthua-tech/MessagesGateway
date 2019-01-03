defmodule DbAgent.Operators do
  use Ecto.Schema
  import Ecto.Changeset
  alias DbAgent.OperatorTypes

  @primary_key {:id, :binary_id, autogenerate: true}

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

  @spec changeset(operators :: Operators.t(), %{}) :: Ecto.Changeset.t()
  def changeset(operators, attrs) do
    operators
    |> cast(attrs, [:name, :operator_type_id, :config, :priority, :price, :limit, :protocol_name, :active])
    |> validate_required([:name, :operator_type_id, :config, :priority, :price, :limit, :protocol_name, :active])
    |> unique_constraint(:name)
    |> foreign_key_constraint(:operator_type_id)
  end
end
