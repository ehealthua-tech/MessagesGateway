defmodule DbAgent.ContactsRequests do
  @moduledoc false

  def list_contacts(params) do
    %UserSearch{}
    |> user_changeset(params)
    |> search(params, User)
  end
end
