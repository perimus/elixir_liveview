defmodule LiveviewTestWeb.GitProjectsLive do
  use LiveviewTestWeb, :live_view

  alias LiveviewTest.GitRepos

  def mount(_params, _session, socket) do
    {:ok, assign_defaults(socket)}
  end

  def render(assigns) do
    ~L"""
    <h1>Trending Git Repos</h1>
    <div id="repos">
      <form phx-change="filter">
        <div class="filters">
          <select name="language">
            <%= options_for_select(add_select_line("language"), @language) %>
          </select>
          <select name="license">
            <%= options_for_select(add_select_line("license"), @license) %>
          </select>
          <a phx-click="click" href="#">Clear All</a>
        </div>
      </form>
      <div class="repos">
      <ul>
        <%= for repo <- @repos do %>
          <li>
            <div class="first-line">
              <div class="group">
                <img src="images/terminal.svg">
                <a href="<%= repo.owner_url %>">
                  <%= repo.owner_login %>
                </a>
                /
                <a href="<%= repo.url %>">
                  <%= repo.name %>
                </a>
              </div>
              <button>
                <img src="images/star.svg">
                Star
              </button>
            </div>
            <div class="second-line">
              <div class="group">
                <span class="language <%= repo.language %>">
                  <%= repo.language %>
                </span>
                <span class="license">
                  <%= repo.license %>
                </span>
                <%= if repo.fork do %>
                  <img src="images/fork.svg">
                <% end %>
              </div>
              <div class="stars">
                <%= repo.stars %> stars
              </div>
            </div>
          </li>
        <% end %>
      </ul>
    </div>
    </div>
    """
  end

  def handle_event("filter", %{"language" => language, "license" => license}, socket) do
    params = [language: language, license: license]

    socket =
      socket
      |> assign(params)
      |> assign(repos: GitRepos.list_git_repos(params))

    {:noreply, socket}
  end

  def handle_event("click", _, socket) do
    {:noreply, assign_defaults(socket)}
  end

  defp assign_defaults(socket) do
    socket
    |> assign(
      language: "",
      license: "",
      repos: GitRepos.list_git_repos()
    )
  end

  defp add_select_line("language") do
    ["Select language": "", js: "js"] ++ GitRepos.list_languages()
  end

  defp add_select_line("license") do
    ["Select license": ""] ++ GitRepos.list_licenses()
  end
end
