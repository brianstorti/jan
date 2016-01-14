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

  # SERVER

  def init(_) do
    {:ok, Map.new}
  end

  def handle_call({:whereis, room_id}, _, state) do
    {:reply, Map.get(state, room_id, :undefined), state}
  end

  def handle_call({:register, room_id}, _, state) do
    {:ok, pid} = GenServer.start_link(Jan.GameServer, [])
    {:reply, pid, Map.put(state, room_id, pid)}
  end
end
