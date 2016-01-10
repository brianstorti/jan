defmodule Jan.PageController do
  use Jan.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
