defmodule Jan.RoomChannelTest do
  use Jan.ChannelCase

  alias Jan.RoomChannel

  setup do
    Jan.Registry.unregister("foo")

    {:ok, _, socket} = subscribe_and_join(socket, RoomChannel, "rooms:foo", %{"player_name" => "Brian"})
    {:ok, socket: socket}
  end

  test "assigns player name when joining", %{socket: socket} do
    assert "Brian", socket.assigns.player_name
  end

  test "fails to join if there is same player name in the room", %{socket: socket} do
    message = "There is already a 'Brian' in this room"
    {:error, ^message} = subscribe_and_join(socket, RoomChannel, "rooms:foo", %{"player_name" => "Brian"})
  end

  test "broadcasts players list" do
    assert_broadcast "players_changed", %{players: [%{name: "Brian", move: nil}]}
  end

  test "adds new player" do
    subscribe_and_join(socket, RoomChannel, "rooms:foo", %{"player_name" => "Storti"})
    assert_broadcast "players_changed", %{players: [%{name: "Storti", move: nil},
                                                    %{name: "Brian", move: nil}]}
  end

  test "registers new move", %{socket: socket} do
    push socket, "new_move", %{"move" => "rock"}
    assert_broadcast "players_changed", %{players: [%{name: "Brian", move: "rock"}]}
  end

  test "broadcasts winner", %{socket: socket} do
    {:ok, _, new_socket} = subscribe_and_join(socket, RoomChannel, "rooms:foo", %{"player_name" => "Storti"})
    push socket, "new_move", %{"move" => "rock"}
    push new_socket, "new_move", %{"move" => "paper"}

    assert_broadcast "winner_found", %{"player_name" => "Storti"}
  end

  test "broadcasts draw", %{socket: socket} do
    {:ok, _, new_socket} = subscribe_and_join(socket, RoomChannel, "rooms:foo", %{"player_name" => "Storti"})
    push socket, "new_move", %{"move" => "rock"}
    push new_socket, "new_move", %{"move" => "rock"}

    assert_broadcast "draw", %{}
  end

  test "starts a new game", %{socket: socket} do
    push socket, "new_move", %{"move" => "rock"}
    assert_broadcast "players_changed", %{players: [%{name: "Brian", move: "rock"}]}

    push socket, "new_game"
    assert_broadcast "players_changed", %{players: [%{name: "Brian", move: nil}]}
  end

  test "removes player when he/she leaves a room", %{socket: socket} do
    subscribe_and_join(socket, RoomChannel, "rooms:foo", %{"player_name" => "Storti"})
    push socket, "leave", %{}
    assert_broadcast "players_changed", %{players: [%{name: "Storti", move: nil}]}
  end

  test "creates new message", %{socket: socket} do
    push socket, "new_message", %{"message" => "some message"}
    assert_broadcast "new_message", %{message: "some message", player: "Brian"}
  end
end
