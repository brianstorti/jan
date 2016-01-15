defmodule Jan.GameServer do
  use GenServer

  alias Jan.Player

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :game_server)
  end

  def add_player(pid, player_name) do
    GenServer.cast(pid, {:add_player, player_name})
  end

  def remove_player(pid, player_name) do
    GenServer.cast(pid, {:remove_player, player_name})
  end

  def new_move(pid, player_name, move) do
    case GenServer.call(pid, {:new_move, player_name, move}) do
      {:winner, winner} -> winner
      _ -> :continue
    end
  end

  def get_players_list(pid) do
    GenServer.call(pid, :players_list)
  end

  def init(_) do
    {:ok, []}
  end

  def handle_cast({:add_player, player_name}, state) do
    {:noreply, [%{name: player_name, move: nil} | state]}
  end

  def handle_cast({:remove_player, player_name}, state) do
    {:noreply, Enum.filter(state, &(&1.name != player_name))}
  end

  def handle_call(:players_list, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:new_move, player_name, move}, _from, state) do
    new_state = Enum.map(state, fn player ->
      if player.name == player_name do
        player = %{player | move: move}
      end

      player
    end)

    {:reply, answer_for(new_state), new_state}
  end

  #[{name: "Foo", move: "rock"},
  # {name: "Bar", move: "paper"}]
  defp answer_for(players) do
    all_players_moved = players |> Enum.map(&(&1.move)) |> Enum.all?

    if all_players_moved do
      {:winner, List.first(players)}
    else
      :continue
    end
  end
end
