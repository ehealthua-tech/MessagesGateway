defmodule DbAgent.Repo.Migrations.CreateOperators do
  use Ecto.Migration

  def change do
    create table(:operators, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: false)
      add(:operator_type_id, references(:operator_type, type: :uuid), null: true) #@todo null true
      add(:config, :jsonb)
      add(:priority, :integer)
      add(:price, :integer,  default: 0, null: 0)
      add(:limit, :integer)
      add(:active, :boolean)

      timestamps()
    end

    create unique_index(:operator, [:name, :operator_type_id])
  end
end
