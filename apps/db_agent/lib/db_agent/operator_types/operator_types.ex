defmodule DbAgent.OperatorTypes do
  use Ecto.Schema
  import Ecto.Changeset


  schema "operator_types" do
    field(:active, :boolean, default: false)
    field(:name, :string, null: false)

    timestamps()
  end

  @doc false
  def changeset(operator_types, attrs) do
    operator_types
    |> cast(attrs, [:name, :active])
    |> validate_required([:name, :active])
    |> unique_constraint(:name)
  end
end
