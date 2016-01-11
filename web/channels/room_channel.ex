defmodule Jan.RoomChannel do
  use Phoenix.Channel

  def join("rooms:" <> room_id, _params, socket) do
    {:ok, socket}
  end
end
