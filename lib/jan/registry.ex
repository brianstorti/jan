defmodule Jan.Registry do
  @moduledoc """
  This module is responsible for storing and retrieving a process for a given room.

  We have a process for each room, and use the room id to identify them.
  When a new room is created, we add a new entry in this `Map`, using the room id
  as the key and the pid as a value.

  These processes are supervised by the `Jan.GameSupervisor` module.
  """

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

  def registered_rooms do
    map = GenServer.call(:process_registry, :registered_rooms)
    Map.keys(map)
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

  def handle_call(:registered_rooms, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:unregister, room_id}, state) do
    {:noreply, Map.delete(state, room_id)}
  end
end
