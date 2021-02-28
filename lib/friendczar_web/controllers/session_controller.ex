defmodule FriendczarWeb.SessionController do
  use FriendczarWeb, :controller

  def new(conn, _) do
    render(conn, "new.html")
  end
end
