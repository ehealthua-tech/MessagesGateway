defmodule DbAgent.ContactsRequests do
  @moduledoc false

  alias DbAgent.Contacts, as: ContactsSchema
  alias DbAgent.Repo

  import Ecto.Query
  import Ecto.Changeset

  @spec list_contacts :: [ContactsSchema.t()] | [] | {:error, Ecto.Changeset.t()}
  def list_contacts() do
    Repo.all(ContactsSchema)
  end

  @spec add_contact(params :: Keyword.t()) :: ContactsSchema.t() | [] | {:error, Ecto.Changeset.t()}
  def add_contact(params) do
    %ContactsSchema{}
    |> ContactsSchema.changeset(params)
    |> Repo.insert()
  end

#  @spec change_phone_number(contact :: ContactsSchema.t(), %{}) :: {:ok, ContactsSchema.t()} | {:error, Ecto.Changeset.t()}
  def change_contact(params) do
    ContactsSchema
    |> where([ot], ot.phone_number == ^params.phone_number)
    |> Repo.update_all( set: [viber_id: params.viber_id, operator_id: params.operator_id])
  end

  def get_by_phone_number!(phone_number) do
    ContactsSchema
    |> where([con], con.phone_number == ^phone_number)
    |> Repo.one()
  end

  def add_viber_id(params) do
    get_by_phone_number!(params.phone_number)
    |> insert_or_update(params)
  end

  def add_operator_id(params) do
    get_by_phone_number!(params.phone_number)
    |> insert_or_update(params)
  end

  def insert_or_update(nil, params), do: add_contact(params)
  def insert_or_update(present_contact, params), do: change_contact(params)

end
