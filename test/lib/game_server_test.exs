defmodule Jan.GameServerTest do
  use ExUnit.Case, async: true

  alias Jan.GameServer

  test "adds and removes players" do
    {:ok, pid} = GameServer.start_link
    assert Enum.empty?(GameServer.get_players_list(pid))

    GameServer.add_player(pid, "Brian")
    assert [%{name: "Brian", move: "", score: 0}] == GameServer.get_players_list(pid)

    GameServer.remove_player(pid, "Brian")
    assert [] == GameServer.get_players_list(pid)
  end

  test "registers moves" do
    {:ok, pid} = GameServer.start_link
    GameServer.add_player(pid, "Brian")
    GameServer.new_move(pid, "Brian", "rock")

    assert [%{name: "Brian", move: "rock", score: 1}] == GameServer.get_players_list(pid)
  end

  test "computes score for winner" do
    {:ok, pid} = GameServer.start_link
    GameServer.add_player(pid, "Brian")
    GameServer.add_player(pid, "Storti")

    GameServer.new_move(pid, "Brian", "rock")
    GameServer.new_move(pid, "Storti", "paper")

    brian = %{name: "Brian", score: 0, move: "rock"}
    storti = %{name: "Storti", score: 1, move: "paper"}

    assert [storti, brian] == GameServer.get_players_list(pid)
  end

  test "resets game" do
    {:ok, pid} = GameServer.start_link
    GameServer.add_player(pid, "Brian")
    GameServer.new_move(pid, "Brian", "rock")
    GameServer.reset_game(pid)

    assert [%{name: "Brian", move: "", score: 1}] == GameServer.get_players_list(pid)
  end
end
