defmodule Jan.GameServer do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :game_server)
  end

  def add_player(pid, player_name) do
    GenServer.cast(pid, {:add_player, player_name})
  end

  def remove_player(pid, player_name) do
    GenServer.cast(pid, {:remove_player, player_name})
  end

  def get_players_list(pid) do
    GenServer.call(pid, :players_list)
  end

  def init(_) do
    {:ok, []}
  end

  def handle_cast({:add_player, player_name}, state) do
    {:noreply, [player_name | state]}
  end

  def handle_cast({:remove_player, player_name}, state) do
    {:noreply, List.delete(state, player_name)}
  end

  def handle_call(:players_list, _from, state) do
    {:reply, state, state}
  end
end
