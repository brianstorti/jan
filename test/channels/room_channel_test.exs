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
    assert_broadcast "players_changed", %{players: [%{name: "Brian", weapon: ""}]}
  end

  test "adds new player" do
    subscribe_and_join(socket, RoomChannel, "rooms:foo", %{"player_name" => "Storti"})
    assert_broadcast "players_changed", %{players: [%{name: "Brian", weapon: ""},
                                                    %{name: "Storti", weapon: ""}]}
  end

  test "registers new weapon", %{socket: socket} do
    push socket, "choose_weapon", %{"weapon" => "rock"}
    assert_broadcast "players_changed", %{players: [%{name: "Brian", weapon: "rock"}]}
  end

  test "broadcasts winner", %{socket: socket} do
    {:ok, _, new_socket} = subscribe_and_join(socket, RoomChannel, "rooms:foo", %{"player_name" => "Storti"})
    push socket, "choose_weapon", %{"weapon" => "rock"}
    push new_socket, "choose_weapon", %{"weapon" => "paper"}

    assert_broadcast "result_found", %{"message" => "Storti won!"}
  end

  test "broadcasts draw", %{socket: socket} do
    {:ok, _, new_socket} = subscribe_and_join(socket, RoomChannel, "rooms:foo", %{"player_name" => "Storti"})
    push socket, "choose_weapon", %{"weapon" => "rock"}
    push new_socket, "choose_weapon", %{"weapon" => "rock"}

    assert_broadcast "result_found", %{"message" => "It's a draw."}
  end

  test "starts a new game", %{socket: socket} do
    push socket, "choose_weapon", %{"weapon" => "rock"}
    assert_broadcast "players_changed", %{players: [%{name: "Brian", weapon: "rock"}]}

    push socket, "new_game"
    assert_broadcast "players_changed", %{players: [%{name: "Brian", weapon: ""}]}
  end

  test "removes player when he/she leaves a room", %{socket: socket} do
    subscribe_and_join(socket, RoomChannel, "rooms:foo", %{"player_name" => "Storti"})
    push socket, "leave", %{}
    assert_broadcast "players_changed", %{players: [%{name: "Storti", weapon: ""}]}
  end

  test "creates new message", %{socket: socket} do
    push socket, "new_message", %{"message" => "some message"}
    assert_broadcast "new_message", %{message: "some message", player: "Brian"}
  end
end
