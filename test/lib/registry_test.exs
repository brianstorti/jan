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

  test "unregisters processes" do
    first_pid = Registry.where_is("foo")
    Registry.unregister("foo")
    second_pid = Registry.where_is("foo")

    assert first_pid != second_pid
  end

  test "gets list of registered rooms" do
    Registry.where_is("foo")
    Registry.where_is("bar")

    assert Registry.registered_rooms == ["bar", "foo"]
  end
end
