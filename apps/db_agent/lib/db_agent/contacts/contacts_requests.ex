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

  @spec change_contact(contact :: ContactsSchema.t(), %{}) :: {:ok, ContactsSchema.t()} | {:error, Ecto.Changeset.t()}
  def change_contact(%ContactsSchema{} = contact, attrs) do
    contact
    |> ContactsSchema.changeset(attrs)
    |> Repo.update()
  end

  def change_contact(contact_info) do
    with updates <-
           get_by_id!(Map.get(contact_info, "phone_number"))
           |> change(contact_info)
      do
      Repo.update(updates)
    end
  end

  def get_by_id!(phone_number) do
    ContactsSchema
    |> where([con], con.phone_number == ^phone_number)
    |> Repo.one!()
  end

end
