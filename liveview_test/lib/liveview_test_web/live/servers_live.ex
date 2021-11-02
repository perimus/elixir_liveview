defmodule LiveviewTestWeb.ServersLive do
  use LiveviewTestWeb, :live_view

  alias LiveviewTest.Servers
  alias LiveviewTest.Servers.Server

  def mount(_params, _session, socket) do
    if connected?(socket), do: Servers.subscribe()

    servers = Servers.list_servers()

    socket =
      assign(
        socket,
        servers: servers
      )

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    id = String.to_integer(id)

    server = Servers.get_server!(id)

    socket =
      assign(socket,
        selected_server: server,
        page_title: "What's up #{server.name}?"
      )

    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    if socket.assigns.live_action == :new do
      changeset = Servers.change_server(%Server{})

      socket =
        assign(socket,
          selected_server: nil,
          changeset: changeset
        )

      {:noreply, socket}
    else
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
        socket =
          push_patch(socket,
            to:
              Routes.live_path(
                socket,
                __MODULE__,
                id: server.id
              )
          )

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

  def handle_event("toggle-status", %{"id" => id}, socket) do
    server = Servers.get_server!(id)

    {:ok, _server} = Servers.toggle_server_status(server)

    {:noreply, socket}
  end

  def handle_info({:server_created, server}, socket) do
    {:noreply, update(socket, :servers, &[server | &1])}
  end

  def handle_info({:event_updated, server}, socket) do
    socket =
      if server.id == socket.assigns.selected_server.id do
        assign(socket, selected_server: server)
      else
        socket
      end

    servers = Servers.list_servers()
    socket = assign(socket, servers: servers)

    socket =
      update(socket, :servers, fn servers ->
        for s <- servers do
          case s.id == server.id do
            true -> server
            _ -> s
          end
        end
      end)

    {:noreply, socket}
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
              <%= live_patch link_body(server),
                to: Routes.live_path(
                    @socket,
                    __MODULE__,
                    id: server.id
                ),
                class: if server == @selected_server, do: "active" %>
          <% end %>
        </nav>
      </div>
      <div class="main">
        <div class="wrapper">
          <%= if @live_action == :new do %>
            <%= f = form_for @changeset, "#",
                      phx_submit: "save",
                      phx_change: "validate" %>
              <div class="field">
                <%= label f, :name %>
                <%= text_input f, :name, placeholder: "Name", autocomplete: "off", phx_debounce: "500" %>
                <%= error_tag f, :name %>
              </div>

              <div class="field">
                <%= label f, :framework %>
                <%= text_input f, :framework, placeholder: "Framework", autocomplete: "off" %>
                <%= error_tag f, :framework %>
              </div>

              <div class="field">
                <%= label f, :size, "Size (MB)" %>
                <%= number_input f, :size, placeholder: "10", autocomplete: "off", phx_debounce: "blur"%>
                <%= error_tag f, :size %>
              </div>

              <div class="field">
                  <%= label f, :git_repo, "Git Repo" %>
                  <%= text_input f, :git_repo, placeholder: "http://example.com", autocomplete: "off" %>
                  <%= error_tag f, :git_repo %>
              </div>

              <%= submit "Submit", phx_disable_with: "Saving..."%>

              <%= live_patch "Cancel",
                  to: Routes.live_path(@socket, __MODULE__),
                  class: "cancel" %>

            </form>
          <% else %>
            <div class="card">
              <div class="header">
                <h2><%= @selected_server.name %></h2>
                <button class="<%= @selected_server.status %>"
                        phx-value-id="<%= @selected_server.id %>"
                        phx-click="toggle-status"
                        phx-disable-with="Saving...">
                  <%= @selected_server.status %>
                </button>
              </div>
              <div class="body">
                <div class="row">
                  <div class="deploys">
                    <img src="/images/deploy.svg">
                    <span>
                    <%= @selected_server.deploy_count %> deploys
                    </span>
                  </div>
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
            </div>
          <% end %>
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
