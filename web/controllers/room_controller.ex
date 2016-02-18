defmodule Jan.RoomController do
  use Jan.Web, :controller
  import Jan.Router.Helpers
  alias Jan.Endpoint

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", room: id)
  end

  def play_with_stranger(conn, _params) do
    random_room_id = Jan.PlayWithStrangerWaitingList.pop
    redirect conn, to: room_path(Endpoint, :show, random_room_id)
  end
end
