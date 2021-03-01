defmodule Friendczar.AuthenticationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Friendczar.Authentication` context.
  """

  def unique_person_email, do: "person#{System.unique_integer()}@example.com"
  def valid_person_password, do: "hello world!"

  def person_fixture(attrs \\ %{}) do
    {:ok, person} =
      attrs
      |> Enum.into(%{
        email: unique_person_email(),
        password: valid_person_password()
      })
      |> Friendczar.Authentication.register_person()

    person
  end

  def extract_person_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end
end
