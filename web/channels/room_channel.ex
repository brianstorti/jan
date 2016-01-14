defmodule Jan.RoomChannel do
  use Phoenix.Channel

  def join("rooms:" <> room_id, params, socket) do
    pid = Jan.Registry.where_is(room_id)
    player_name = Map.get(params, "player_name")

    Jan.GameServer.add_player(pid, player_name)

    send self, :new_player_joined
    {:ok, assign(socket, :pid, pid)}
  end

  def handle_info(:new_player_joined, socket) do
    players = Jan.GameServer.get_players_list(socket.assigns.pid)
    broadcast! socket, "new_player_joined", %{players: players}
    {:noreply, socket}
  end

  def handle_in("new_move", %{"body" => body}, socket) do
    # broadcast!/3 will notify all joined clients on this socket's topic and
    # invoke their handle_out/3 callbacks
    broadcast! socket, "new_move", %{"body" => body}
    {:noreply, socket}
  end
end
