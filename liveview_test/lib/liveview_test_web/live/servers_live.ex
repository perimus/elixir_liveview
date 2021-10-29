defmodule LiveviewTestWeb.ServersLive do
  use LiveviewTestWeb, :live_view

  alias LiveviewTest.Servers
  alias LiveviewTest.Servers.Server

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()

    changeset = Servers.change_server(%Server{})

    socket =
      assign(
        socket,
        servers: servers,
        selected_server: hd(servers),
        changeset: changeset
      )

    {:ok, socket, temporary_assigns: [servers: []]}
  end

  def handle_params(%{"name" => name}, _url, socket) do
    selected_server = Servers.get_server_by_name(name)

    {
      :noreply,
      assign(
        socket,
        selected_server: selected_server,
        page_title: "What's up #{selected_server.name}?"
      )
    }
  end

  def handle_params(_, _url, socket) do
    {:noreply, socket}
  end

  # This "handle_params" clause needs to assign socket data
  # based on whether the action is "new" or not.
  def handle_params(_params, _url, socket) do
    if socket.assigns.live_action == :new do
      # The live_action is "new", so the form is being
      # displayed. Therefore, assign an empty changeset
      # for the form. Also don't show the selected
      # server in the sidebar which would be confusing.

      changeset = Servers.change_server(%Server{})

      socket =
        assign(socket,
          selected_server: nil,
          changeset: changeset
        )

      {:noreply, socket}
    else
      # The live_action is NOT "new", so the form
      # is NOT being displayed. Therefore, don't assign
      # an empty changeset. Instead, just select the
      # first server in list. This previously happened
      # in "mount", but since "handle_params" is always
      # invoked after "mount", we decided to select the
      # default server here instead of in "mount".

      socket =
        assign(socket,
          selected_server: hd(socket.assigns.servers)
        )

      {:noreply, socket}
    end
  end

  def handle_event("save", %{"server" => params}, socket) do
    case Servers.create_server(params) do
      {:ok, server} ->
        socket = update(socket, :servers, &[server | &1])

        changeset = Servers.change_server(%Server{})

        socket = assign(socket, changeset: changeset)

        :timer.sleep(500)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"server" => params}, socket) do
    changeset =
      %Server{}
      |> Servers.change_server(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def render(assigns) do
    ~L"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <nav>
          <div class="add">
            <%= live_patch "New Server",
            to: Routes.servers_path(@socket, :new),
            class: "button" %>
          </div id="servers" phx-update="prepend">
          <%= for server <- @servers do %>
            <div id="server">
              <%= live_patch link_body(server),
                to: Routes.live_path(
                    @socket,
                    __MODULE__,
                    name: server.name
                ),
                class: if server == @selected_server, do: "active" %>
            </div>
          <% end %>
        </nav>
      </div>
      <div class="main">
        <div class="wrapper">
          <div class="card">
            <%= if @live_action == :new do %>
              <%= f = form_for @changeset, "#",
              phx_submit: "save",
              phx_change: "validate" %>
                <div class="field">
                  <label>
                    Name
                    <%= text_input f, :name, placeholder: "Name", autocomplete: "off", phx_debounce: "500" %>
                    <%= error_tag f, :name %>
                  </label>

                </div>
                <div class="field">
                  <label>
                    Framework
                    <%= text_input f, :framework, placeholder: "Framework", autocomplete: "off" %>
                    <%= error_tag f, :framework %>
                  </label>

                </div>
                <div class="field">
                  <label>
                    Size (MB)
                    <%= number_input f, :size, placeholder: "10", autocomplete: "off", phx_debounce: "blur"%>
                    <%= error_tag f, :size %>
                  </label>

                </div>
                <div class="field">
                  <label>
                    Git Repo
                    <%= text_input f, :git_repo, placeholder: "http://example.com", autocomplete: "off" %>
                    <%= error_tag f, :git_repo %>
                  </label>
                </div>

                <%= submit "Submit", phx_disable_with: "Saving..."%>

                <a href="#" class="cancel">
                  Cancel
                </a>

              </form>
            <% else %>
            <div class="header">
              <h2><%= @selected_server.name %></h2>
              <span class="<%= @selected_server.status %>">
                <%= @selected_server.status %>
              </span>
            </div>
            <div class="body">
              <div class="row">
                <div class="deploys">
                  <img src="/images/deploy.svg">
                  <span>
                  <%= @selected_server.deploy_count %> deploys
                  </span>
                  <span>
                    <%= @selected_server.size %> MB
                  </span>
                  <span>
                    <%= @selected_server.framework %>
                  </span>
                </div>
                <h3>Git Repo</h3>
                <div class="repo">
                  <%= @selected_server.git_repo %>
                </div>
                <h3>Last Commit</h3>
                <div class="commit">
                  <%= @selected_server.last_commit_id %>
                </div>
                <blockquote>
                  <%= @selected_server.last_commit_message %>
                </blockquote>
              </div>
            <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp link_body(server) do
    assigns = %{name: server.name, status: server.status}

    ~L"""
    <span class="status <%= @status %>"></span>
    <img src="/images/server.svg">
    <%= @name %>
    """
  end
end
