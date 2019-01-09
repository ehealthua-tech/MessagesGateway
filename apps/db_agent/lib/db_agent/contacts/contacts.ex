defmodule DbAgent.Contacts do
  use Ecto.Schema
  import Ecto.Changeset
  alias DbAgent.Operators

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
               id: String.t(),
               phone_number: String.t(),
               viber_id:  String.t(),
               operator: String.t(),

               inserted_at: NaiveDateTime.t(),
               updated_at: NaiveDateTime.t()
             }

  @type contacts_map :: %{
                          id: String.t(),
                          phone_number: String.t(),
                          viber_id:  String.t(),
                          operator: String.t()
                        }

  schema "contacts" do
    field(:phone_number, :string,  null: false)
    field(:viber_id, :string, null: true)
    belongs_to(:operator, Operators, foreign_key: :operator_id, type: :binary_id)
    timestamps()
  end

  @spec changeset(contacts :: t, any()) :: Ecto.Changeset.t()
  def changeset(contacts, attrs) do
    contacts
    |> cast(attrs, [:phone_number, :viber_id, :operator_id])
    |> validate_required([:phone_number])
    |> unique_constraint(:phone_number)
  end
end
