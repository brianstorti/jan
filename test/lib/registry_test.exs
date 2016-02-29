defmodule Jan.RegistryTest do
  use ExUnit.Case, async: true

  alias Jan.Registry

  test "registers processes" do
    Jan.GameSupervisor.start_game("foo")
    Jan.GameSupervisor.start_game("bar")

    first_pid = Registry.whereis_name({:game_server, "foo"})
    second_pid = Registry.whereis_name({:game_server, "foo"})
    third_pid = Registry.whereis_name({:game_server, "bar"})

    assert first_pid == second_pid
    assert first_pid != third_pid
  end
end
