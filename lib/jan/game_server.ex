defmodule Jan.GameServer do
  use GenServer

  alias Jan.Player

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def add_player(pid, player_name) do
    case GenServer.call(pid, {:add_player, player_name}) do
      :ok -> :ok
      :duplicate -> {:error, "There is already a '#{player_name}' in this room"}
      :empty -> {:error, "The name must be filled in"}
    end
  end

  def remove_player(pid, player_name) do
    GenServer.cast(pid, {:remove_player, player_name})
  end

  def choose_weapon(pid, player_name, weapon) do
    case GenServer.call(pid, {:choose_weapon, player_name, weapon}) do
      {:winner, winner} ->
        GenServer.cast(pid, {:increment_winner_score, winner})
        {:winner, winner}
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

  def handle_call({:add_player, player_name}, _from, state) do
    cond do
      Enum.any?(state, &(String.downcase(&1.name) == String.downcase(player_name))) ->
        {:reply, :duplicate, state}

      String.strip(player_name) == "" ->
        {:reply, :empty, state}

      true ->
        {:reply, :ok, [%{name: player_name, weapon: "", score: 0} | state]}
    end
  end

  def handle_cast({:remove_player, player_name}, state) do
    {:noreply, Enum.filter(state, &(&1.name != player_name))}
  end

  def handle_cast({:increment_winner_score, winner}, state) do
    new_state = Enum.map(state, fn player ->
      if player.name == winner.name do
        player = %{player | score: player.score + 1}
      end

      player
    end)

    {:noreply, new_state}
  end

  def handle_call(:players_list, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:choose_weapon, player_name, weapon}, _from, state) do
    new_state = Enum.map(state, fn player ->
      if player.name == player_name do
        player = %{player | weapon: weapon}
      end

      player
    end)

    {:reply, answer_for(new_state), new_state}
  end

  def handle_cast(:reset_game, state) do
    {:noreply, Enum.map(state, &(%{&1 | weapon: ""}))}
  end

  defp answer_for(players) do
    all_players_moved = players |> Enum.map(&(&1.weapon)) |> Enum.all?(&(&1 != ""))

    if all_players_moved do
      find_winner(players)
    end
  end

  defp find_winner(players) do
    is_winner = fn current -> beat_all?(current.weapon, List.delete(players, current)) end
    winner = Enum.find(players, is_winner)

    if winner do
      {:winner, winner}
    else
      :draw
    end
  end

  defp beat_all?(weapon, players) do
    this_beat_that = %{"rock" => "scissors",
                       "paper" => "rock",
                       "scissors" => "paper"}

    weapon_to_beat = Map.get(this_beat_that, weapon)

    Enum.all?(players, &(&1.weapon == weapon_to_beat))
  end
end
