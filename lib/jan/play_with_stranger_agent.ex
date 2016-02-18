defmodule Jan.PlayWithStrangerAgent do

  def start_link do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def pop do
    case Agent.get(__MODULE__, fn room_name -> room_name end) do
      nil ->
        room_name = random_room_name
        Agent.update(__MODULE__, fn _room_nem -> room_name end)
        room_name

      room_name ->
        Agent.update(__MODULE__, fn _room_nem -> nil end)
        room_name
    end
  end

  defp random_room_name do
    length = 5
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end
end
