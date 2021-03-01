defmodule FriendczarWeb.PersonSessionController do
  use FriendczarWeb, :controller

  alias Friendczar.Authentication
  alias FriendczarWeb.PersonAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"person" => person_params}) do
    %{"email" => email, "password" => password} = person_params

    if person = Authentication.get_person_by_email_and_password(email, password) do
      PersonAuth.log_in_person(conn, person, person_params)
    else
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> PersonAuth.log_out_person()
  end
end
