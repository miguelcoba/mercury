defmodule MercuryWeb.ProductLive.Show do
  use MercuryWeb, :live_view

  alias Mercury.Products

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Show course")
     |> assign(:product, Products.get_product!(id))}
  end
end
