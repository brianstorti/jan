defmodule Jan.Router do
  use Jan.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Jan do
    pipe_through :browser

    get "/", RoomController, :new
    get "/rooms/:id", RoomController, :show
    get "/play_with_stranger", RoomController, :play_with_stranger
    get "/admin", AdminController, :index
  end
end
