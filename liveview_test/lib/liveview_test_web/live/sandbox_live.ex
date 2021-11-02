defmodule LiveviewTestWeb.SandboxLive do
  use LiveviewTestWeb, :live_view

  alias LiveviewTestWeb.QuoteComponent
  alias LiveviewTestWeb.SandboxCalculatorComponent

  def mount(_params, _session, socket) do
    {:ok, assign(socket, weight: nil, price: nil)}
  end

  def render(assigns) do
    ~L"""
    <h1>Build A Sandbox</h1>

    <div id="sandbox">
      <%= live_component @socket, SandboxCalculatorComponent, id: 1, coupon: 10.0 %>

      <%= if @weight do %>
        <%= live_component @socket, QuoteComponent, material: "sand", weight: @weight, price: @price %>
      <% end %>
    </div>
    """
  end

  def handle_info({:totals, weight, price}, socket) do
    socket = assign(socket, price: price, weight: weight)
    {:noreply, socket}
  end
end
