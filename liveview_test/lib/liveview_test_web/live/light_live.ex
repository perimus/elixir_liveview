defmodule LiveviewTestWeb.LightLive do
  use LiveviewTestWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(
        socket,
        brightness: 10,
        temp: 3000
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Disco</h1>
    <div id="light">
      <div class="meter">
        <span style="background-color: <%= temp_color(@temp) %>; width: <%= @brightness %>%">
          <%= @brightness %>%
        </span>
      </div>

      <div class="content">
        <form phx-change="update">
          <%= for temp <- [3000, 4000, 5000] do %>
            <%= temp_radio_button(temp: temp, checked: temp == @temp) %>
          <% end %>
        </form>
      </div>
    </div>
    """
  end

  def handle_event("update", %{"temp" => temp}, socket) do
    temp = String.to_integer(temp)
    {:noreply, assign(socket, temp: temp)}
  end

  defp temp_color(3000), do: "#F1C40D"
  defp temp_color(4000), do: "#FEFF66"
  defp temp_color(5000), do: "#99CCFF"

  defp temp_radio_button(assigns) do
    assigns = Enum.into(assigns, %{})

    ~L"""
    <input type="radio" id="<%= @temp %>" name="temp" value="<%= @temp %>"
            <%= if @checked, do: "checked" %> />
    <label for="<%= @temp %>"><%= @temp %></label>
    """
  end
end
