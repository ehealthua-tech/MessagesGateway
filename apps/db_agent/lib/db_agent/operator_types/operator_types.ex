defmodule DbAgent.OperatorTypes do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "operator_types" do
    field(:active, :boolean, default: false)
    field(:name, :string, null: false)
    field(:priority, :integer)

    timestamps()
  end

  @spec changeset(operator_types :: OperatorTypes.t(), %{}) :: Ecto.Changeset.t()
  def changeset(operator_types, attrs) do
    operator_types
    |> cast(attrs, [:name, :active, :priority])
    |> validate_required([:name, :active, :priority])
    |> unique_constraint(:name)
  end

end


