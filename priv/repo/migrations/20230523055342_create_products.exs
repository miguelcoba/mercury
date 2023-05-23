defmodule Mercury.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :images, {:array, :string}

      timestamps()
    end
  end
end
