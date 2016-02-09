defmodule Jan.AdminController do
  use Jan.Web, :controller
  plug PlugBasicAuth, validation: &Jan.AdminController.is_authorized/2

  def index(conn, _params) do
    rooms = Jan.Registry.registered_rooms
    render(conn, "index.html", rooms: rooms)
  end

  def is_authorized(user, pass) do
    if user == Application.get_env(:jan, :admin_user) &&
       pass == Application.get_env(:jan, :admin_password) do
      :authorized
    else
      :unauthorized
    end
  end
end
