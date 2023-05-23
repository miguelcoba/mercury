defmodule MercuryWeb.ProductLive.FormComponent do
  use MercuryWeb, :live_component

  alias Mercury.Products

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage product records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="product-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.label for="#images">Images</.label>

        <.error :for={{msg, _} <- @form[:images].errors}><%= msg %></.error>

        <div id="images">
          <div class="flex flex-row flex-wrap justify-start items-start text-center text-slate-500 gap-2 mb-8">
            <div :for={image <- @images_to_show} class="border shadow-md pb-1">
              <figure class="w-32 h-32 overflow-clip">
                <img src={image} />
              </figure>
              <a
                phx-click="remove"
                phx-target={@myself}
                phx-value-image={image}
                class="hover:text-slate-800"
              >
                <.icon name="hero-trash" />
              </a>
            </div>
          </div>

          <div
            class="p-4 border-2 border-dashed border-slate-300 rounded-md text-center text-slate-600"
            phx-drop-target={@uploads.images.ref}
          >
            <div class="flex flex-row items-center justify-center">
              <.live_file_input upload={@uploads.images} />
              <span class="font-semibold text-slate-500">or drag and drop here</span>
            </div>

            <div class="mt-4">
              <.error :for={err <- upload_errors(@uploads.images)}>
                <%= Phoenix.Naming.humanize(err) %>
              </.error>
            </div>

            <div class="mt-4 flex flex-row flex-wrap justify-start content-start items-start gap-2">
              <div
                :for={entry <- @uploads.images.entries}
                class="flex flex-col items-center justify-start space-y-1"
              >
                <div class="w-32 h-32 overflow-clip">
                  <.live_img_preview entry={entry} />
                </div>

                <div class="w-full">
                  <div class="mb-2 text-xs font-semibold inline-block text-slate-600">
                    <%= entry.progress %>%
                  </div>
                  <div class="flex h-2 overflow-hidden text-base bg-slate-200 rounded-lg mb-2">
                    <span style={"width: #{entry.progress}%"} class="shadow-md bg-slate-500"></span>
                  </div>
                  <.error :for={err <- upload_errors(@uploads.images, entry)}>
                    <%= Phoenix.Naming.humanize(err) %>
                  </.error>
                </div>
                <a phx-click="cancel" phx-target={@myself} phx-value-ref={entry.ref}>
                  <.icon name="hero-trash" />
                </a>
              </div>
            </div>
          </div>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Product</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @max_entries 3
  @max_file_size 5_000_000

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:removed_images, [])

    {:ok, socket}
  end

  @impl true
  def update(%{product: product} = assigns, socket) do
    changeset = Products.change_product(product)
    images_to_show = product.images -- socket.assigns.removed_images

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> assign(:images_to_show, images_to_show)
     |> allow_upload(:images,
       accept: ~w(.png .jpg .jpeg),
       max_entries: @max_entries,
       max_file_size: @max_file_size
     )}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    images_to_show = socket.assigns.images_to_show

    socket =
      socket
      |> validate_images(product_params, images_to_show)

    {:noreply, socket}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    images_to_show = socket.assigns.images_to_show

    images =
      consume_uploaded_entries(socket, :images, fn meta, entry ->
        filename = "#{entry.uuid}#{Path.extname(entry.client_name)}"
        dest = Path.join(MercuryWeb.uploads_dir(), filename)

        File.cp!(meta.path, dest)

        {:ok, ~p"/uploads/#{filename}"}
      end)

    product_params = Map.put(product_params, "images", images_to_show ++ images)

    save_product(socket, socket.assigns.action, product_params)
  end

  def handle_event("cancel", %{"ref" => ref}, socket) do
    images_to_show = socket.assigns.images_to_show

    socket =
      socket
      |> cancel_upload(:images, ref)
      |> validate_images(%{}, images_to_show)

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove", %{"image" => image}, socket) do
    product = socket.assigns.product
    removed_images = [image | socket.assigns.removed_images]
    images_to_show = product.images -- removed_images

    socket =
      socket
      |> assign(:removed_images, removed_images)
      |> assign(:images_to_show, images_to_show)
      |> validate_images(%{}, images_to_show)

    {:noreply, socket}
  end

  defp save_product(socket, :edit, product_params) do
    case Products.update_product(socket.assigns.product, product_params) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_product(socket, :new, product_params) do
    case Products.create_product(product_params) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp validate_images(socket, product_params, images_to_show) do
    images =
      socket.assigns.uploads.images.entries
      |> Enum.map(fn entry ->
        filename = "#{entry.uuid}#{Path.extname(entry.client_name)}"
        ~p"/uploads/#{filename}"
      end)

    product_params = Map.put(product_params, "images", images_to_show ++ images)

    changeset =
      socket.assigns.product
      |> Products.change_product(product_params)
      |> Map.put(:action, :validate)

    assign_form(socket, changeset)
  end
end
