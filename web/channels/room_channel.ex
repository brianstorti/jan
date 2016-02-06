defmodule Jan.RoomChannel do
  use Phoenix.Channel

  def join("rooms:" <> room_id, %{"player_name" => player_name}, socket) do
    pid = Jan.Registry.where_is(room_id)
    socket = socket
              |> assign(:pid, pid)
              |> assign(:player_name, player_name)

    case Jan.GameServer.add_player(pid, player_name) do
      :ok ->
        send self, :players_changed
        {:ok, socket}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def handle_info(:players_changed, socket) do
    players = Jan.GameServer.get_players_list(socket.assigns.pid)
    broadcast! socket, "players_changed", %{players: Enum.reverse(players)}

    {:noreply, socket}
  end

  def handle_in("choose_weapon", %{"weapon" => weapon}, socket) do
    pid = socket.assigns.pid
    player_name = socket.assigns.player_name

    case Jan.GameServer.choose_weapon(pid, player_name, weapon) do
      {:winner, player} ->
        broadcast! socket, "result_found", %{"message" => "#{player.name} won!"}

      :draw ->
        broadcast! socket, "result_found", %{"message" => "It's a draw."}

      _ -> nil
    end

    send self, :players_changed

    {:noreply, socket}
  end

  def handle_in("start_new_game", _, socket) do
    Jan.GameServer.reset_game(socket.assigns.pid)
    send self, :players_changed
    broadcast!  socket, "reset_game", %{}

    {:noreply, socket}
  end

  def handle_in("new_message", %{"message" => message}, socket) do
    broadcast! socket, "new_message", %{message: message, player: socket.assigns.player_name}
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
