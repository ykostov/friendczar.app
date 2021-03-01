defmodule FriendczarWeb.SessionController do
  use FriendczarWeb, :controller

  alias Friendczar.Accounts


  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Accounts.sign_in(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "You have signed in")
        |> redirect(to: Routes.room_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "Invalid Email or Password")
        |> render("new.html")
    end
  end
end
