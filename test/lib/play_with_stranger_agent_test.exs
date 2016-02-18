defmodule Jan.PlayWithStrangerWaitingListTest do
  use ExUnit.Case, async: true

  alias Jan.PlayWithStrangerAgent

  test "gets room name" do
    first_room = PlayWithStrangerAgent.pop
    second_room = PlayWithStrangerAgent.pop
    third_room = PlayWithStrangerAgent.pop

    assert first_room == second_room
    assert first_room != third_room
  end
end
