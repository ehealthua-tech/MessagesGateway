defmodule DbAgent.Operators do
  use Ecto.Schema
  import Ecto.Changeset
  alias DbAgent.OperatorTypes


  schema "operators" do
    field(:name, :string, null: false)
    field(:config, :map)
    field(:priority, :integer)
    field(:price, :integer,  default: 0, null: 0)
    field(:limit, :integer)
    field(:active, :boolean, default: false)

    belongs_to(:operator_types_id, OperatorTypes)

    timestamps()
  end

  @doc false

  def changeset(operators, attrs) do
    operators
    |> cast(attrs, [:name, :config, :priority, :price, :limit, :active])
    |> validate_required([:name, :active])
    |> unique_constraint(:name)
    |> foreign_key_constraint(:operator_types_id)
  end
end
