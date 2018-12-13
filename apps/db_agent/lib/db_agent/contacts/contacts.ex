defmodule DbAgent.Contacts do
  use Ecto.Schema
  import Ecto.Changeset
  alias DbAgent.Operators

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "contacts" do
    field(:phone_number, :string,  null: false)

    belongs_to(:operator, Operators, foreign_key: :operator_id, type: :binary_id)
    timestamps()
  end

  def changeset(contacts, attrs) do
    contacts
    |> cast(attrs, [:phone_number, :operator])
    |> validate_required([:phone_number])
    |> unique_constraint(:phone_number)
  end
end
