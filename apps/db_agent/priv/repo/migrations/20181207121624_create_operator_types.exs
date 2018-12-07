defmodule DbAgent.Repo.Migrations.CreateOperatorTypes do
  use Ecto.Migration

  def change do
    create table(:operator_types, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: false)
      add(:active, :boolean, default: false, null: false)

      timestamps()
    end

    create unique_index(:operator_types, [:name])
  end
end
