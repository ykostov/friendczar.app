defmodule Friendczar.Repo.Migrations.CreatePersonsAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:persons) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:persons, [:email])

    create table(:persons_tokens) do
      add :person_id, references(:persons, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:persons_tokens, [:person_id])
    create unique_index(:persons_tokens, [:context, :token])
  end
end
