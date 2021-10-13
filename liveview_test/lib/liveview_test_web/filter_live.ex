defmodule LiveviewTestWeb.FilterLive do
  use LiveviewTestWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(
        socket,
        type: "",
        price: "",
        boats: [],
        loading: false
      )
    {:ok, socket}
  end
end
