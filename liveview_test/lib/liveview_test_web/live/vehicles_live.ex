defmodule LiveviewTestWeb.VehiclesLive do
  use LiveviewTestWeb, :live_view

  alias LiveviewTest.Vehicles

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, total_vehicles: Vehicles.count_vehicles(), temporary_assigns: [vehicles: []])}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "5")

    pagination_options = %{page: page, per_page: per_page}

    sort_by = (params["sort_by"] || "id") |> String.to_atom()
    sort_order = (params["sort_order"] || "asc") |> String.to_atom()

    sort_options = %{sort_by: sort_by, sort_order: sort_order}

    vehicles = Vehicles.list_vehicles(pagination: pagination_options, sort: sort_options)

    {
      :noreply,
      assign(
        socket,
        options: Map.merge(pagination_options, sort_options),
        vehicles: vehicles
      )
    }
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    per_page = String.to_integer(per_page)

    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            page: socket.assigns.options.page,
            per_page: per_page,
            sort_by: socket.assigns.options.sort_by,
            sort_order: socket.assigns.options.sort_order
          )
      )

    {:noreply, socket}
  end

  defp live_pagination(socket, text, page, options, class) do
    live_patch(
      text,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          page: page,
          per_page: options.per_page,
          sort_by: options.sort_by,
          sort_order: options.sort_order
        ),
      class: class
    )
  end

  defp sort_link(socket, text, sort_by, options) do
    text =
      if sort_by == options.sort_by do
        text <> emoji(options.sort_order)
      else
        text
      end

    live_patch(text,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          sort_by: sort_by,
          page: options.page,
          per_page: options.per_page,
          sort_order: change_order(options.sort_order)
        )
    )
  end

  defp change_order(:asc), do: :desc
  defp change_order(:desc), do: :asc

  defp emoji(:asc), do: "up"
  defp emoji(:desc), do: "down"
end
