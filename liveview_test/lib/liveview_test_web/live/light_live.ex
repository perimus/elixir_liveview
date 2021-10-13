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
          <input type="radio" id="3000" name="temp" value="3000"
          <%= if @temp == 3000, do: "checked" %> />
          <label for="3000">3000</label>
          <input type="radio" id="4000" name="temp" value="4000"
          <%= if @temp == 4000, do: "checked" %> />
          <label for="4000">4000</label>
          <input type="radio" id="5000" name="temp" value="5000"
          <%= if @temp == 5000, do: "checked" %>/>
          <label for="5000">5000</label>
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

end
