defmodule Jan.PlayWithStrangerWaitingList do

  use GenServer

  # API

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :waiting_list)
  end

  def pop do
    case GenServer.call(:waiting_list, :pop) do
      nil ->
        GenServer.call(:waiting_list, :create_room)

      room_name ->
        room_name
    end
  end

  # SERVER

  def init(_) do
    {:ok, nil}
  end

  def handle_call(:pop, _from, state) do
    {:reply, state, nil}
  end

  def handle_call(:create_room, _from, state) do
    new_room = random_room_name
    {:reply, new_room, new_room}
  end

  defp random_room_name do
    length = 5
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end
end
