defmodule LiveviewTestWeb.FilterLive do
  use LiveviewTestWeb, :live_view

  alias LiveviewTest.Boats

  def mount(_params, _session, socket) do
    {:ok, assign_defaults(socket), temporary_assigns: [boats: []]}
  end

  def render(assigns) do
    ~L"""
    <h1>Daily Boat Rentals</h1>
    <div id="filter">
      <form phx-change="filter">
        <div class="filters">
          <select name="type">
            <%= options_for_select(add_all_types(), @type) %>
          </select>
          <div class="prices">
            <input type="hidden" name="prices[]" value="" />
            <%= for price <- Boats.list_prices  do %>
              <%= price_checkbox(%{price: price, checked: price in @prices}) %>
            <% end %>
          </div>
          <a phx-click="clear-filters" href="#">Clear All</a>
        </div>
      </form>

      <div class="boats">
        <%= for boat <- @boats do %>
          <div class="card">
            <img src="<%= boat.image %>">
            <div class="content">
              <div class="model">
                <%= boat.model %>
              </div>
              <div class="details">
                <span class="price">
                  <%= boat.price %>
                </span>
                <span class="type">
                  <%= boat.type %>
                </span>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("filter", %{"type" => type, "prices" => prices}, socket) do
    params = [type: type, prices: prices]

    socket =
      socket
      |> assign(params)
      |> assign_boats(params)

    {:noreply, socket}
  end

  def handle_event("clear-filters", _, socket) do
    {:noreply, assign_defaults(socket)}
  end

  defp add_all_types do
    ["All Types": ""] ++ Boats.list_types()
  end

  defp price_checkbox(assigns) do
    ~L"""
    <input
      type="checkbox"
      name="prices[]"
      id="<%= @price %>"
      value="<%= @price %>"
      <%= if @checked, do: "checked" %> />
    <label for="<%= @price %>"><%= @price %></label>
    """
  end

  defp assign_defaults(socket) do
    socket
    |> assign(
      type: "",
      prices: [],
      boats: Boats.list_boats()
    )
  end

  def assign_boats(socket, params) do
    socket
    |> assign(boats: Boats.list_boats(params))
  end
end
