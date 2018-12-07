defmodule DbAgent.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:phone_number, :string,  null: false)
      add(:operator_id, references(:operators, type: :uuid), null: true)

      timestamps()
    end

    create unique_index(:contacts, [:phone_number])
  end
end
