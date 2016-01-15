defmodule Jan.Router do
  use Jan.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Jan do
    pipe_through :browser # Use the default browser stack

    get "/:id", RoomController, :show
    resources "rooms", RoomController
  end
end
