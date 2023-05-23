defmodule Mercury.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :images, {:array, :string}
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :images])
    |> validate_required([:name, :images])
  end
end
