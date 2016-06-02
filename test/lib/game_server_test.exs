defmodule Jan.GameServerTest do
  use ExUnit.Case, async: true

  alias Jan.GameServer

  test "adds and removes players" do
    {:ok, _pid} = GameServer.start_link("room_id")
    assert Enum.empty?(GameServer.get_players_list("room_id"))

    GameServer.add_player("room_id", "Brian")
    GameServer.add_player("room_id", "Storti")
    assert [%{name: "Storti", weapon: "", score: 0}, %{name: "Brian", weapon: "", score: 0}] == GameServer.get_players_list("room_id")

    GameServer.remove_player("room_id", "Brian")
    assert [%{name: "Storti", weapon: "", score: 0}] == GameServer.get_players_list("room_id")
  end

  test "exits when there are no players left" do
    {:ok, pid} = GameServer.start_link("room_id")
    assert Enum.empty?(GameServer.get_players_list("room_id"))

    GameServer.add_player("room_id", "Brian")
    assert [%{name: "Brian", weapon: "", score: 0}] == GameServer.get_players_list("room_id")

    ref = Process.monitor(pid)
    GameServer.remove_player("room_id", "Brian")
    assert_receive {:DOWN, ^ref, _, _, _}
  end

  test "handles duplicated name" do
    GameServer.start_link("room_id")

    assert :ok == GameServer.add_player("room_id", "Brian")
    assert {:error, "There is already a 'Brian' in this room"} ==  GameServer.add_player("room_id", "Brian")
  end

  test "handles empty name" do
    GameServer.start_link("room_id")

    assert {:error, "The name must be filled in"} ==  GameServer.add_player("room_id", "")
  end

  test "can't join a game if it already started" do
    GameServer.start_link("room_id")
    GameServer.add_player("room_id", "Brian")
    GameServer.choose_weapon("room_id", "Brian", "rock")

    assert {:error, "There's a game being played in this room already"} ==  GameServer.add_player("room_id", "Storti")
  end

  test "registers new weapon" do
    GameServer.start_link("room_id")
    GameServer.add_player("room_id", "Brian")
    GameServer.choose_weapon("room_id", "Brian", "rock")

    assert [%{name: "Brian", weapon: "rock", score: 1}] == GameServer.get_players_list("room_id")
  end

  test "computes score for winner" do
    GameServer.start_link("room_id")
    GameServer.add_player("room_id", "Brian")
    GameServer.add_player("room_id", "Storti")

    GameServer.choose_weapon("room_id", "Brian", "rock")
    GameServer.choose_weapon("room_id", "Storti", "paper")

    brian = %{name: "Brian", score: 0, weapon: "rock"}
    storti = %{name: "Storti", score: 1, weapon: "paper"}

    assert [storti, brian] == GameServer.get_players_list("room_id")
  end

  test "resets game" do
    GameServer.start_link("room_id")
    GameServer.add_player("room_id", "Brian")
    GameServer.choose_weapon("room_id", "Brian", "rock")
    GameServer.reset_game("room_id")

    assert [%{name: "Brian", weapon: "", score: 1}] == GameServer.get_players_list("room_id")
  end
end
