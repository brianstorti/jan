defmodule Jan.Registry do
  @moduledoc """
  This module is responsible for storing and retrieving a process for a given room.

  We have a process for each room, and use the room id to identify them.
  When a new room is created, we add a new entry in this `Map`, using the room id
  as the key and the pid as a value.
  """

  use GenServer
  import Kernel, except: [send: 2]

  # API

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def whereis_name(room_id) do
    GenServer.call(:process_registry, {:whereis_name, room_id})
  end

  def register_name(room_id, pid) do
    GenServer.call(:process_registry, {:register_name, room_id, pid})
  end

  def unregister_name(room_id) do
    GenServer.cast(:process_registry, {:unregister_name, room_id})
  end

  def send(room_id, message) do
    case whereis_name(room_id) do
      :undefined ->
        {:badarg, {room_id, message}}

      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  def registered_rooms do
    rooms = GenServer.call(:process_registry, :registered_rooms)
    keys = Map.keys(rooms)
    Keyword.get_values(keys, :game_server)
  end

  # SERVER

  def init(_) do
    {:ok, Map.new}
  end

  def handle_call({:whereis_name, room_id}, _from, state) do
    {:reply, Map.get(state, room_id, :undefined), state}
  end

  def handle_call({:register_name, room_id, pid}, _from, state) do
    case Map.get(state, room_id) do
      nil ->
        Process.monitor(pid)
        {:reply, :yes, Map.put(state, room_id, pid)}

      _ ->
        {:reply, :no, state}
    end
  end

  def handle_info({:DOWN, _, :process, pid, _}, state) do
    new_state = deregister_pid(state, pid)
    {:noreply, new_state}
  end

  def handle_call(:registered_rooms, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:unregister_name, room_id}, state) do
    {:noreply, Map.delete(state, room_id)}
  end

  defp deregister_pid(state, pid) do
    Enum.reduce(
      state,
      state,
      fn
        ({registered_alias, registered_process}, registry_acc) when registered_process == pid ->
          Map.delete(registry_acc, registered_alias)

        (_, registry_acc) -> registry_acc
      end
    )
  end
end
