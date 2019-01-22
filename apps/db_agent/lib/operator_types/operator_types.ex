defmodule DbAgent.OperatorTypes do
  @moduledoc """
    Operator_types schema description
  """

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

  schema "operator_types" do
    field(:active, :boolean, default: false)
    field(:name, :string, null: false)
    field(:priority, :integer)
    timestamps()
  end

  @spec changeset(operator_types, attrs) :: result when
          operator_types: t(),
          attrs: map(),
          result: Ecto.Changeset.t()

  def changeset(operator_types, attrs) do
    operator_types
    |> cast(attrs, [:name, :active, :priority])
    |> validate_required([:name, :active, :priority])
    |> unique_constraint(:name)
  end

end


