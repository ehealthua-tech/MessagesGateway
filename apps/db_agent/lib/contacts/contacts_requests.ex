defmodule DbAgent.ContactsRequests do
  @moduledoc """
    Database requests for contacts
  """

  alias DbAgent.Contacts, as: ContactsSchema
  alias DbAgent.Repo

  import Ecto.Query

  @doc """
    Get all contacts from database
  """
  @spec list_contacts() :: result when
          result: [ContactsSchema.t()] | [] | {:error, Ecto.Changeset.t()}

  def list_contacts() do
    Repo.all(ContactsSchema)
  end

  @doc """
    Add contact to database
  """
  @spec add_contact(params) :: result when
          params: ContactsSchema.contacts_map() | %{phone_number: String.t(), viber_id: String.t},
          result: {:ok, ContactsSchema.t()} | {:error, Ecto.Changeset.t()}

  def add_contact(params) do
    %ContactsSchema{}
    |> ContactsSchema.changeset(params)
    |> Repo.insert()
  end

  @doc """
    Change contact data
  """
  @spec change_contact(params) :: result when
          params: ContactsSchema.contacts_map(),
          result: {integer(), nil | [term()]}

  def change_contact(params) do
    ContactsSchema
    |> where([ot], ot.phone_number == ^params.phone_number)
    |> Repo.update_all( set: [viber_id: params.viber_id, operator_id: params.operator_id])
  end

  @doc """
    Get contact data by phone number
  """
  @spec get_by_phone_number!(phone_number) :: result when
          phone_number: String.t(),
          result: Ecto.Schema.t() | nil

  def get_by_phone_number!(phone_number) do
    ContactsSchema
    |> where([con], con.phone_number == ^phone_number)
    |> Repo.one()
  end

  @doc """
    Add contact viber id
  """
  @spec add_viber_id(params) :: result when
          params: %{phone_number: String.t(), viber_id: String.t},
          result: {:ok, ContactsSchema.t()} | {:error, Ecto.Changeset.t()}

  def add_viber_id(params) do
    get_by_phone_number!(params.phone_number)
    |> insert_or_update(params)
  end

  @doc """
    Add contact operaror id
  """
  @spec add_operator_id(params) :: result when
          params: %{phone_number: String.t(), viber_id: String.t, operator_id: String.t()},
          result: {:ok, ContactsSchema.t()} | {:error, Ecto.Changeset.t()}

  def add_operator_id(params) do
    get_by_phone_number!(params.phone_number)
    |> insert_or_update(params)
  end

  @doc """
    Insert new contact to database or update old contact
  """
  @spec insert_or_update(present_contact, params) :: result when
          present_contact: nil | String.t(),
          params: %{phone_number: String.t(), viber_id: String.t} | %{phone_number: String.t(), viber_id: String.t, operator_id: String.t},
          result: {:ok, ContactsSchema.t()} | {:error, Ecto.Changeset.t()}

  def insert_or_update(nil, params), do: add_contact(params)
  def insert_or_update(_present_contact, params), do: change_contact(params)

  @doc """
    Delete contact by id
  """
  @spec delete(id) :: result when
          id: String.t(),
          result: {integer(), nil | [term()]}

  def delete(id) do
    from(p in ContactsSchema, where: p.id == ^id)
    |> Repo.delete_all()
  end

end
