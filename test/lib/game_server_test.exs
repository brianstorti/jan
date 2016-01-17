defmodule Jan.GameServerTest do
  use ExUnit.Case, async: true

  alias Jan.GameServer

  test "adds and removes players" do
    {:ok, pid} = GameServer.start_link
    assert Enum.empty?(GameServer.get_players_list(pid))

    GameServer.add_player(pid, "Brian")
    assert [%{name: "Brian", move: nil}] == GameServer.get_players_list(pid)

    GameServer.remove_player(pid, "Brian")
    assert [] == GameServer.get_players_list(pid)
  end

  test "registers moves" do
    {:ok, pid} = GameServer.start_link
    GameServer.add_player(pid, "Brian")
    GameServer.new_move(pid, "Brian", "rock")

    assert [%{name: "Brian", move: "rock"}] == GameServer.get_players_list(pid)
  end

  test "resets game" do
    {:ok, pid} = GameServer.start_link
    GameServer.add_player(pid, "Brian")
    GameServer.new_move(pid, "Brian", "rock")
    GameServer.reset_game(pid)

    assert [%{name: "Brian", move: nil}] == GameServer.get_players_list(pid)
  end
end
