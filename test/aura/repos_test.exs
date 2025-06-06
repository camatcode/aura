defmodule Aura.ReposTest do
  use ExUnit.Case

  alias Aura.Repos

  @moduletag :capture_log
  doctest Repos

  doctest Aura.Common

  setup do
    TestHelper.setup_state()
  end

  test "list_repos", _state do
    assert {:ok, [%{name: "hexpm"}]} = Repos.list_repos()
  end

  test "get_repo/1", _state do
    assert {:ok, [hex]} = Repos.list_repos()
    assert {:ok, returned} = Repos.get_repo(hex.name)
    assert returned.name == hex.name
  end
end
