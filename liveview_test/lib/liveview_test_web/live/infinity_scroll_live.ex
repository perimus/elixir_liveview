defmodule LiveviewTestWeb.InfiniteScrollLive do
  use LiveviewTestWeb, :live_view

  alias LiveviewTest.PizzaOrders

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page: 1, per_page: 10)
      |> load_orders()

    {:ok, socket, temporary_assigns: [orders: []]}
  end

  defp load_orders(socket) do
    assign(socket,
      orders:
        PizzaOrders.list_pizza_orders(
          page: socket.assigns.page,
          per_page: socket.assigns.per_page
        )
    )
  end

  def render(assigns) do
    ~L"""
    <div id="infinite-scroll">
      <h1>Pizza Lovers Timeline </h1>
      <div id="orders" phx-update="append">
        <%= for order <- @orders do %>
          <div class="order" id="<%= order.id %>">
            <div class="id">
              <%= order.id %>
            </div>
            <div>
              <div class="pizza">
                <%= order.pizza %>
              </div>
              <div>
                ordered by
                <span class="username">
                  <%= order.username %>
                </span>
              </div>
            </div>
          </div>
        <% end %>
      </div>
      <div id="footer" phx-hook="InfiniteScroll">
        <div class="loader">
          Loading more...
        </div>
      </div>
    </div>
    """
  end

  def handle_event("load-more", _, socket) do
    socket =
      socket
      |> update(:page, &(&1 + 1))
      |> load_orders()

    {:noreply, socket}
  end
end
