defmodule MercuryWeb.ProductLive.Index do
  use MercuryWeb, :live_view

  alias Mercury.Products

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Listing Products")
      |> stream(:products, Products.list_products())

    {:ok, socket}
  end
end
