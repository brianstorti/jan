defmodule Jan.RoomChannel do
  use Phoenix.Channel

  def join("rooms:" <> room_id, params, socket) do
    pid = Jan.Registry.where_is(room_id)
    player_name = Map.get(params, "player_name")

    socket = socket
              |> assign(:pid, pid)
              |> assign(:player_name, player_name)

    Jan.GameServer.add_player(pid, player_name)

    send self, :players_changed
    {:ok, socket}
  end

  def terminate(socket, topic) do
    IO.inspect "LEAVING"
    {:ok, socket}
  end

  def handle_info(:players_changed, socket) do
    IO.inspect "players_changed"
    players = Jan.GameServer.get_players_list(socket.assigns.pid)
    broadcast! socket, "players_changed", %{players: players}
    {:noreply, socket}
  end

  def handle_in("new_move", %{"move" => move}, socket) do
    # broadcast!/3 will notify all joined clients on this socket's topic and
    # invoke their handle_out/3 callbacks
    IO.inspect "#{socket.assigns.player_name} chooses #{move}"
    # broadcast! socket, "new_move", %{"body" => body}
    {:noreply, socket}
  end

  def handle_in("leave", _, socket) do
    pid = socket.assigns.pid
    player_name = socket.assigns.player_name

    Jan.GameServer.remove_player(pid, player_name)
    broadcast! socket, "players_changed", %{players: Jan.GameServer.get_players_list(pid)}

    {:stop, :normal, :ok, socket}
  end
end
