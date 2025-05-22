defmodule Aura.ReposTest do
  use ExUnit.Case

  alias Aura.Repos

  doctest Repos

  test "get_all_repos/0" do
    assert [%{name: "hexpm"}] = Repos.get_all_repos()
  end
end
