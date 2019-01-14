defmodule DbAgent.ContactsRequests do
  @moduledoc false

  alias DbAgent.Contacts, as: ContactsSchema
  alias DbAgent.Repo

  import Ecto.Query

  @spec list_contacts :: [ContactsSchema.t()] | [] | {:error, Ecto.Changeset.t()}
  def list_contacts() do
    Repo.all(ContactsSchema)
  end

  @spec add_contact(params :: ContactsSchema.contacts_map()) :: {:ok, ContactsSchema.t()} | {:error, Ecto.Changeset.t()}
  def add_contact(params) do
    %ContactsSchema{}
    |> ContactsSchema.changeset(params)
    |> Repo.insert()
  end

  @spec change_contact(params :: ContactsSchema.contacts_map()) :: {integer(), nil | [term()]}
  def change_contact(params) do
    ContactsSchema
    |> where([ot], ot.phone_number == ^params.phone_number)
    |> Repo.update_all( set: [viber_id: params.viber_id, operator_id: params.operator_id])
  end

  @spec get_by_phone_number!(phone_number :: String.t()) :: Ecto.Schema.t() | nil
  def get_by_phone_number!(phone_number) do
    ContactsSchema
    |> where([con], con.phone_number == ^phone_number)
    |> Repo.one()
  end

  @spec add_viber_id(params :: ContactsSchema.contacts_map()) :: {:ok, ContactsSchema.t()} | {:error, Ecto.Changeset.t()}
  def add_viber_id(params) do
    get_by_phone_number!(params.phone_number)
    |> insert_or_update(params)
  end

  @spec add_operator_id(params :: ContactsSchema.contacts_map()) :: {:ok, ContactsSchema.t()} | {:error, Ecto.Changeset.t()}
  def add_operator_id(params) do
    get_by_phone_number!(params.phone_number)
    |> insert_or_update(params)
  end

  @spec insert_or_update(present_contact :: nil | String.t(), params :: ContactsSchema.contacts_map()) :: {:ok, ContactsSchema.t()} | {:error, Ecto.Changeset.t()}
  def insert_or_update(nil, params), do: add_contact(params)
  def insert_or_update(present_contact, params), do: change_contact(params)

  @spec delete(id :: String.t()) :: {integer(), nil | [term()]}
  def delete(id) do
    from(p in ContactsSchema, where: p.id == ^id)
    |> Repo.delete_all()
  end

end
