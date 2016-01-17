defmodule Jan.RegistryTest do
  use ExUnit.Case, async: true

  alias Jan.Registry

  test "registers processes" do
    first_pid = Registry.where_is("foo")
    second_pid = Registry.where_is("foo")
    third_pid = Registry.where_is("bar")

    assert first_pid == second_pid
    assert first_pid != third_pid
  end
end
