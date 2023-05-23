defmodule Mercury.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :images, {:array, :string}
    field :name, :string

    timestamps()
  end

  @max_files 3

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :images])
    |> validate_required([:name, :images])
    |> validate_length(:images, max: @max_files, message: "Max number of images is #{@max_files}")
  end
end
