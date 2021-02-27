defmodule Friendczar.Talk do
  alias Friendczar.Repo
  alias Friendczar.Talk.Room

  def list_rooms do
    Repo.all(Room)
  end
end
