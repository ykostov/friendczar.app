defmodule FriendczarWeb.PersonSettingsController do
  use FriendczarWeb, :controller

  alias Friendczar.Authentication
  alias FriendczarWeb.PersonAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "person" => person_params} = params
    person = conn.assigns.current_person

    case Authentication.apply_person_email(person, password, person_params) do
      {:ok, applied_person} ->
        Authentication.deliver_update_email_instructions(
          applied_person,
          person.email,
          &Routes.person_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.person_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "person" => person_params} = params
    person = conn.assigns.current_person

    case Authentication.update_person_password(person, password, person_params) do
      {:ok, person} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:person_return_to, Routes.person_settings_path(conn, :edit))
        |> PersonAuth.log_in_person(person)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Authentication.update_person_email(conn.assigns.current_person, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.person_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.person_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    person = conn.assigns.current_person

    conn
    |> assign(:email_changeset, Authentication.change_person_email(person))
    |> assign(:password_changeset, Authentication.change_person_password(person))
  end
end
