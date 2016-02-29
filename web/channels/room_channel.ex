defmodule Jan.RoomChannel do
  use Phoenix.Channel

  def join("rooms:" <> room_id, %{"player_name" => player_name}, socket) do
    Jan.GameSupervisor.start_game(room_id)

    socket = socket
              |> assign(:player_name, player_name)
              |> assign(:room_id, room_id)

    case Jan.GameServer.add_player(room_id, player_name) do
      :ok ->
        send self, :players_changed
        {:ok, socket}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def handle_info(:players_changed, socket) do
    broadcast_players_change(socket)

    {:noreply, socket}
  end

  def handle_in("choose_weapon", %{"weapon" => weapon}, socket) do
    room_id = socket.assigns.room_id
    player_name = socket.assigns.player_name

    case Jan.GameServer.choose_weapon(room_id, player_name, weapon) do
      {:winner, player} ->
        broadcast! socket, "result_found", %{"message" => "#{player.name} won!"}

      :draw ->
        broadcast! socket, "result_found", %{"message" => "It's a draw."}

      _ -> nil
    end

    broadcast_players_change(socket)

    {:noreply, socket}
  end

  def handle_in("start_new_game", _, socket) do
    Jan.GameServer.reset_game(socket.assigns.room_id)
    broadcast_players_change(socket)
    broadcast!  socket, "reset_game", %{}

    {:noreply, socket}
  end

  def handle_in("new_message", %{"message" => message}, socket) do
    broadcast! socket, "new_message", %{message: message, player: socket.assigns.player_name}
    {:noreply, socket}
  end

  def handle_in("leave", _, socket) do
    room_id = socket.assigns.room_id
    player_name = socket.assigns.player_name

    Jan.GameServer.remove_player(room_id, player_name)
    broadcast_players_change(socket)

    {:stop, :normal, :ok, socket}
  end

  defp broadcast_players_change(socket) do
    players = Jan.GameServer.get_players_list(socket.assigns.room_id)
    broadcast! socket, "players_changed", %{players: Enum.reverse(players)}
  end
end
