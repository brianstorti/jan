defmodule Jan.RoomController do
  use Jan.Web, :controller

  alias Jan.Room

  def new(conn, _params) do
    changeset = Room.changeset(%Room{})
    render(conn, "new.html", changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", room: id)
  end
end
