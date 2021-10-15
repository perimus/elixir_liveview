defmodule LiveviewTestWeb.Router do
  use LiveviewTestWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LiveviewTestWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveviewTestWeb do
    pipe_through :browser

    live "/", PageLive, :index
    live "/light", LightLive
    live "/license", LicenseLive
    live "/sales-dashboard", SalesDashboardLive
    live "/search", SearchLive
    live "/flight", FlightLive
    live "/autocomplete", AutoCompleteLive
    live "/filter", FilterLive
    live "/git-projects", GitProjectsLive
    live "/servers", ServersLive
    live "/paginate", PaginateLive
    live "/vehicles", VehiclesLive
    live "/sort", SortLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveviewTestWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: LiveviewTestWeb.Telemetry
    end
  end
end
