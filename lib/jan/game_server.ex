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
      {:winner, winner} -> {:winner, winner}
      other_result -> other_result
    end
  end

  def reset_game(pid) do
    GenServer.cast(pid, :reset_game)
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

  def handle_cast(:reset_game, state) do
    {:noreply, Enum.map(state, &(%{&1 | move: nil}))}
  end

  defp answer_for(players) do
    all_players_moved = players |> Enum.map(&(&1.move)) |> Enum.all?

    if all_players_moved do
      find_winner(players)
    else
      :continue
    end
  end

  defp find_winner(players) do
    p1 = List.first(players)
    p2 = List.last(players)
    this_beat_that = %{"rock" => "scissors", "paper" => "rock", "scissors" => "paper"}

    cond do
      Map.get(this_beat_that, p1.move) == p2.move -> {:winner, p1}
      Map.get(this_beat_that, p2.move) == p1.move -> {:winner, p2}
      true -> :draw
    end
  end
end
