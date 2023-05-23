defmodule Mercury.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Mercury.Products` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        images: ["option1", "option2"],
        name: "some name"
      })
      |> Mercury.Products.create_product()

    product
  end
end
