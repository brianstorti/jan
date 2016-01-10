defmodule Jan.RoomControllerTest do
  use Jan.ConnCase

  alias Jan.Room
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, room_path(conn, :new)
    assert html_response(conn, 200) =~ "New room"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, room_path(conn, :create), room: @valid_attrs
    assert redirected_to(conn) == room_path(conn, :index)
    assert Repo.get_by(Room, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, room_path(conn, :create), room: @invalid_attrs
    assert html_response(conn, 200) =~ "New room"
  end

  test "shows chosen resource", %{conn: conn} do
    room = Repo.insert! %Room{}
    conn = get conn, room_path(conn, :show, room)
    assert html_response(conn, 200) =~ "Show room"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, room_path(conn, :show, -1)
    end
  end
end
