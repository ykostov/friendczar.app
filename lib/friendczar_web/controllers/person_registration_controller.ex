defmodule FriendczarWeb.PersonRegistrationController do
  use FriendczarWeb, :controller

  alias Friendczar.Authentication
  alias Friendczar.Authentication.Person
  alias FriendczarWeb.PersonAuth

  def new(conn, _params) do
    changeset = Authentication.change_person_registration(%Person{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"person" => person_params}) do
    case Authentication.register_person(person_params) do
      {:ok, person} ->
        {:ok, _} =
          Authentication.deliver_person_confirmation_instructions(
            person,
            &Routes.person_confirmation_url(conn, :confirm, &1)
          )

        conn
        |> put_flash(:info, "Person created successfully.")
        |> PersonAuth.log_in_person(person)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
