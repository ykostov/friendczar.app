defmodule FriendczarWeb.RoomController do
  use FriendczarWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
