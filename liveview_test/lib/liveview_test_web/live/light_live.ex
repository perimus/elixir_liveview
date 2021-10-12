defmodule LiveviewTestWeb.LightLive do
  use LiveviewTestWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, :brightness, 10)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Disco</h1>
    <div id="light">
      <div class="meter">
        <span style="width: <%= @brightness %>%">
          <%= @brightness %>%
        </span>
      </div>

      <button phx-click="random">
        Light me up!
      </button>
    </div>
    """
  end

  def handle_event("random", _, socket) do
    Benchee.run(
      %{
         "Erlang" => fn -> :rand.uniform(100) end,
         "Elixir" => fn -> Enum.random(0..100) end,
      },
      time: 100
    )
    {:noreply, assign(socket, :brightness, :rand.uniform(100))}
  end
end
