defmodule Aura.ReposTest do
  use ExUnit.Case

  alias Aura.Repos

  doctest Repos

  test "list_repos/0" do
    assert {:ok, [%{name: "hexpm"}]} = Repos.list_repos()
  end

  test "get_repo/1" do
    assert {:ok, [hex]} = Repos.list_repos()
    assert {:ok, returned} = Repos.get_repo(hex.name)
    assert returned.name == hex.name
  end
end
