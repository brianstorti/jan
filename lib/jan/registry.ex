defmodule Jan.Registry do
  use GenServer

  # API

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def where_is(room_id) do
    case GenServer.call(:process_registry, {:whereis, room_id}) do
      :undefined -> GenServer.call(:process_registry, {:register, room_id})
      pid -> pid
    end
  end

  def unregister(room_id) do
    GenServer.cast(:process_registry, {:unregister, room_id})
  end

  # SERVER

  def init(_) do
    {:ok, Map.new}
  end

  def handle_call({:whereis, room_id}, _from, state) do
    {:reply, Map.get(state, room_id, :undefined), state}
  end

  # As we are not trapping exits to unregister processes, if a registered process
  # dies we will keep this invalid PID, which will cause issues for a room wih
  # the same name
  def handle_call({:register, room_id}, _from, state) do
    {:ok, pid} = Jan.GameSupervisor.start_game
    {:reply, pid, Map.put(state, room_id, pid)}
  end

  def handle_cast({:unregister, room_id}, state) do
    {:noreply, Map.delete(state, room_id)}
  end
end
