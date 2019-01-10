defmodule DbAgent.OperatorTypes do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
               id: String.t() | nil,
               active: boolean | nil,
               name:  String.t() | nil,
               priority: integer | nil,
               inserted_at: NaiveDateTime.t()| nil,
               updated_at: NaiveDateTime.t() | nil
             }

  @type operator_types_map :: %{
                          id: String.t(),
                          active: boolean,
                          name:  String.t(),
                          priority: integer
                        }


  schema "operator_types" do
    field(:active, :boolean, default: false)
    field(:name, :string, null: false)
    field(:priority, :integer)
    timestamps()
  end

  @spec changeset(operator_types :: t(), map()) :: Ecto.Changeset.t()
  def changeset(operator_types, attrs) do
    operator_types
    |> cast(attrs, [:name, :active, :priority])
    |> validate_required([:name, :active, :priority])
    |> unique_constraint(:name)
  end

end


