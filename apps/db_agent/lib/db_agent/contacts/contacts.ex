defmodule DbAgent.Contacts do
  use Ecto.Schema
  import Ecto.Changeset
  alias DbAgent.Operators


  schema "contacts" do
    field(:phone_number, :string,  null: false)

    belongs(:operator_id, Operators)

    timestamps()
  end

  @doc false
  def changeset(operator_type, attrs) do
    operator_type
    |> cast(attrs, [:phone_number])
    |> validate_required([:phone_number])
    |> unique_constraint(:phone_number)
    |> foreign_key_constraint(:name)
  end
end
