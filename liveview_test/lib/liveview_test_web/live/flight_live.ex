defmodule LiveviewTestWeb.FlightLive do
  use LiveviewTestWeb, :live_view

  alias LiveviewTest.Flights
  alias LiveviewTest.Airports

  def mount(_params, _session, socket) do
    socket =
      assign(
        socket,
        number: "",
        airport: "",
        flights: Flights.list_flights(),
        matches: [],
        loading: false
      )

    {:ok, socket, temporary_assigns: [flights: []]}
  end

  def render(assigns) do
    ~L"""
    <h1>Find a Flight</h1>
    <div id=search>
      <form phx-submit="number-search">
        <input
          type="text"
          name="number"
          value="<%= @number %>"
          placeholder="Flight Number"
          autofocus
          autocomplete="off"
          <%= if @loading, do: "readonly" %> />

        <button type="submit">
          <img src="images/search.svg">
        </button>
      </form>

      <form phx-submit="airport-search" phx-change="suggest-airport">
        <input
          type="text"
          name="airport"
          value="<%= @airport %>"
          placeholder="Airport"
          autocomplete="off"
          list="matches"
          <%= if @loading, do: "readonly" %> />

        <button type="submit">
          <img src="images/search.svg">
        </button>
      </form>

      <datalist id="matches">
        <%= for match <- @matches do %>
          <option value="<%= match %>">
            <%= match %>
          </option>
        <% end %>
      </datalist>

      <%= if @loading do %>
      <div class="loader">
        Loading...
      </div>

      <% end %>
      <div class="flights">
        <ul>
          <%= for flight <- @flights do %>
            <li>
              <div class="first-line">
                <div class="number">
                  Flight #<%= flight.number %>
                </div>
                <div class="origin-destination">
                  <img src="images/location.svg">
                  <%= flight.origin %>
                  to
                  <%= flight.destination %>
                </div>
              </div>
              <div class="second-line">
                <div class="departs">
                  Departs: <%= format_time(flight.departure_time) %>
                </div>
                <div class="arrives">
                  Arrives: <%= format_time(flight.arrival_time) %>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("number-search", %{"number" => number}, socket) do
    send(self(), {:search_by_number, number})

    socket =
      assign(
        socket,
        number: number,
        flights: [],
        loading: true
      )

    {:noreply, socket}
  end

  def handle_event("airport-search", %{"airport" => airport}, socket) do
    send(self(), {:search_by_airport, airport})

    socket =
      assign(
        socket,
        airport: airport,
        flights: [],
        loading: true
      )

    {:noreply, socket}
  end

  def handle_event("suggest-airport", %{"airport" => prefix}, socket) do
    socket =
      assign(
        socket,
        matches: Airports.suggest(prefix)
      )

    {:noreply, socket}
  end

  def handle_info({:search_by_number, number}, socket) do
    case Flights.search_by_number(number) do
      [] ->
        socket =
          socket
          |> put_flash(:info, "No flights found for \"#{number}\"")
          |> assign(flights: [], loading: false)

        {:noreply, socket}

      flights ->
        socket =
          socket
          |> clear_flash()
          |> assign(flights: flights, loading: false)

        {:noreply, socket}
    end
  end

  def handle_info({:search_by_airport, airport}, socket) do
    case Flights.search_by_airport(airport) do
      [] ->
        socket =
          socket
          |> put_flash(:info, "No flights found for \"#{airport}\"")
          |> assign(flights: [], loading: false)

        {:noreply, socket}

      flights ->
        socket =
          socket
          |> clear_flash()
          |> assign(flights: flights, loading: false)

        {:noreply, socket}
    end
  end

  defp format_time(time) do
    Timex.format!(time, "%b %d at %k:%M", :strftime)
  end
end
