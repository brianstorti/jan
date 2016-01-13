defmodule Jan.RoomChannel do
  use Phoenix.Channel

  intercept ["new_player_joined"]

  def join("rooms:" <> room_id, params, socket) do
    send self, {:new_player_joined, Map.fetch!(params, "player_name")}
    {:ok, socket}
  end

  def handle_info({:new_player_joined, player_name}, socket) do
    broadcast! socket, "new_player_joined", %{name: player_name}
    {:noreply, socket}
  end

  # handle_out/3 isn't a required callback, but it allows us to customize and
  # filter broadcasts before they reach each client
  def handle_out("new_player_joined", payload, socket) do
    players = [payload.name | socket.assigns[:players] || []]
    socket = assign(socket, :players, players)

    push socket, "new_player_joined", %{players: players}
    {:noreply, socket}
  end

  def handle_in("new_move", %{"body" => body}, socket) do
    # broadcast!/3 will notify all joined clients on this socket's topic and
    # invoke their handle_out/3 callbacks
    broadcast! socket, "new_move", %{"body" => body}
    {:noreply, socket}
  end
end
