defmodule Jan.GameServerTest do
  use ExUnit.Case, async: true

  alias Jan.GameServer

  test "adds and removes players" do
    {:ok, pid} = GameServer.start_link
    assert Enum.empty?(GameServer.get_players_list(pid))

    GameServer.add_player(pid, "Brian")
    assert [%{name: "Brian", weapon: "", score: 0}] == GameServer.get_players_list(pid)

    GameServer.remove_player(pid, "Brian")
    assert [] == GameServer.get_players_list(pid)
  end

  test "registers new weapon" do
    {:ok, pid} = GameServer.start_link
    GameServer.add_player(pid, "Brian")
    GameServer.choose_weapon(pid, "Brian", "rock")

    assert [%{name: "Brian", weapon: "rock", score: 1}] == GameServer.get_players_list(pid)
  end

  test "computes score for winner" do
    {:ok, pid} = GameServer.start_link
    GameServer.add_player(pid, "Brian")
    GameServer.add_player(pid, "Storti")

    GameServer.choose_weapon(pid, "Brian", "rock")
    GameServer.choose_weapon(pid, "Storti", "paper")

    brian = %{name: "Brian", score: 0, weapon: "rock"}
    storti = %{name: "Storti", score: 1, weapon: "paper"}

    assert [storti, brian] == GameServer.get_players_list(pid)
  end

  test "resets game" do
    {:ok, pid} = GameServer.start_link
    GameServer.add_player(pid, "Brian")
    GameServer.choose_weapon(pid, "Brian", "rock")
    GameServer.reset_game(pid)

    assert [%{name: "Brian", weapon: "", score: 1}] == GameServer.get_players_list(pid)
  end
end
