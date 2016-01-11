defmodule Jan.RoomChannel do
  use Phoenix.Channel

  def join("rooms:" <> room_id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("new_move", %{"body" => body}, socket) do
    # broadcast!/3 will notify all joined clients on this socket's topic and
    # invoke their handle_out/3 callbacks
    broadcast! socket, "new_move", %{"body" => body}
    {:noreply, socket}
  end

  # handle_out/3 isn't a required callback, but it allows us to customize and
  # filter broadcasts before they reach each client
  def handle_out("new_move", payload, socket) do
    push socket, "new_move", payload
    {:noreply, socket}
  end
end
