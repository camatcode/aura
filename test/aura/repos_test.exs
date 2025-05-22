defmodule Aura.ReposTest do
  use ExUnit.Case

  alias Aura.Repos

  doctest Repos

  test "get_all_repos/0" do
    assert {:ok, [%{name: "hexpm"}]} = Repos.get_all_repos()
  end

  test "get_repo/1" do
    assert {:ok, [hex]} = Repos.get_all_repos()
    assert {:ok, returned} = Repos.get_repo(hex.name)
    assert returned.name == hex.name
  end
end
