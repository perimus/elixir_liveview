defmodule LiveviewTestWeb.SalesDashboardLive do
  use LiveviewTestWeb, :live_view

  alias LiveviewTest.Sales
  use Timex

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_stats()
      |> assign(refresh: 1, last_updated_at: Timex.now())

    if connected?(socket), do: schedule_refresh(socket)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Sales Dashboard</h1>
    <div id="dashboard">
      <div class="stats">
        <div class="stat">
          <span class="value">
            <%= @new_orders %>
          </span>
          <span class="name">
            New Orders
          </span>
        </div>
        <div class="stat">
          <span class="value">
            <%= @sales_amount %>
          </span>
          <span class="name">
            Sales Amount
          </span>
        </div>
        <div class="stat">
          <span class="value">
            <%= @satisfaction %>%
          </span>
          <span class="name">
            Satisfaction
          </span>
        </div>
      </div>

      <div class="controls">
        <form phx-change="select-refresh">
          <label for="refresh">
            Refresh every:
          </label>
          <select name="refresh">
            <%= options_for_select(refresh_options(), @refresh) %>
          </select>
        </form>
        <span>
        Last updated on:
        <%= Timex.format!(@last_updated_at, "%H:%M:%S", :strftime) %>
        </span>
        <button phx-click="refresh">
          <img src="images/refresh.svg">
          Refresh
        </button>
      </div>
    </div>
    """
  end

  def handle_event("refresh", _, socket) do
      socket =
        socket
        |> assign_stats()
        |> assign(last_updated_at: Timex.now)
      {:noreply, socket}
  end

  def handle_event("select-refresh", %{"refresh" => refresh}, socket) do
    refresh = String.to_integer(refresh)
    {:noreply, assign(socket, refresh: refresh)}
  end

  def handle_info(:tick, socket) do
    schedule_refresh(socket)
    socket =
      socket
      |> assign_stats()
      |> assign(last_updated_at: Timex.now)
    {:noreply, socket}
  end

  defp assign_stats(socket) do
    assign(
        socket,
        new_orders: Sales.new_orders(),
        sales_amount: Sales.sales_amount(),
        satisfaction: Sales.satisfaction()
      )
  end

  defp refresh_options do
    [{"1s", 1}, {"5s", 5}, {"15s", 15}, {"30s", 30}, {"60s", 60}]
  end

  defp schedule_refresh(socket) do
    Process.send_after(self(), :tick, socket.assigns.refresh * 1000)
  end
end
