defmodule Jan.RoomController do
  use Jan.Web, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", room: id)
  end
end
