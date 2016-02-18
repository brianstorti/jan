defmodule Jan.PlayWithStrangerWaitingListTest do
  use ExUnit.Case, async: true

  alias Jan.PlayWithStrangerWaitingList

  test "gets room name" do
    first_room = PlayWithStrangerWaitingList.pop
    second_room = PlayWithStrangerWaitingList.pop
    third_room = PlayWithStrangerWaitingList.pop

    assert first_room == second_room
    assert first_room != third_room
  end
end
