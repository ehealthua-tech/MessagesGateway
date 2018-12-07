defmodule DbAgent.OperatorsRequests do
  @moduledoc false
  alias DbAgent.Operators

  def list_operators(params) do
    %Operators{}
    |> user_changeset(params)
    |> search(params, User)
  end

  def change_role(%Operators{} = role) do
    role_changeset(role, %{})
  end

  defp role_changeset(%Operators{} = role, attrs) do
    role
    |> cast(attrs, [:name, :scope])
    |> validate_required([:name, :scope])
    |> unique_constraint(:name)
  end

  defp role_changeset(%OperatorsSearch{} = role, attrs) do
    role
    |> cast(attrs, [:name, :scope])
    |> put_search_change()
  end

  defp put_search_change(%Ecto.Changeset{valid?: true, changes: %{scope: scopes}} = changeset) do
    put_change(changeset, :scope, {String.split(scopes, ","), :intersect})
  end

  defp put_search_change(changeset), do: changeset


end
