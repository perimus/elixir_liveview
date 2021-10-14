defmodule LiveviewTestWeb.PaginateLive do
  use LiveviewTestWeb, :live_view

  alias LiveviewTest.Donations

  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       temporary_assigns: [donations: []]
     )}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "5")

    paginate_options = %{page: page, per_page: per_page}
    donations = Donations.list_donations(paginate: paginate_options)

    {:noreply,
     assign(
       socket,
       options: paginate_options,
       donations: donations,
       temporary_assigns: [donations: []]
     )}
  end

  def handle_params(params, _url, socket) do
    {:noreply, socket}
  end

  defp expires_class(donation) do
    if Donations.almost_expired?(donation), do: "eat-now", else: "fresh"
  end
end
