defmodule MercuryWeb.ProductLive.New do
  use MercuryWeb, :live_view

  alias Mercury.Products.Product

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "New Product")
      |> assign(:product, %Product{})

    {:ok, socket}
  end
end
