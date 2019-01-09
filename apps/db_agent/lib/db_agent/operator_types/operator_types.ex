defmodule DbAgent.OperatorTypes do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
               id: String.t(),
               active: boolean,
               name:  String.t(),
               priority: integer,

               inserted_at: NaiveDateTime.t(),
               updated_at: NaiveDateTime.t()
             }


  schema "operator_types" do
    field(:active, :boolean, default: false)
    field(:name, :string, null: false)
    field(:priority, :integer)

    timestamps()
  end

  @spec changeset(operator_types :: map(), %{}) :: Ecto.Changeset.t()
  def changeset(operator_types, attrs) do
    operator_types
    |> cast(attrs, [:name, :active, :priority])
    |> validate_required([:name, :active, :priority])
    |> unique_constraint(:name)
  end

end


