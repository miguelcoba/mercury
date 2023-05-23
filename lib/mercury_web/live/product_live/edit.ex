defmodule MercuryWeb.ProductLive.Edit do
  use MercuryWeb, :live_view

  alias Mercury.Products

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Edit Course")
     |> assign(:product, Products.get_product!(id))}
  end
end
