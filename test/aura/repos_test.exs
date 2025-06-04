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

  test "api_keys", _state do
    assert {:ok, [api_key]} = Repos.list_api_keys()
    assert api_key.authing_key
    assert api_key.inserted_at
    assert api_key.updated_at
    assert api_key.name
    assert api_key.url

    assert {:ok, retrieved} = Repos.get_api_key(api_key.name)
    assert retrieved.name == api_key.name

    assert :ok = Repos.delete_api_key(api_key.name)
  end

  test "delete all api keys", _state do
    assert :ok = Repos.delete_all_api_keys()
  end

  test "get_repo/1", _state do
    assert {:ok, [hex]} = Repos.list_repos()
    assert {:ok, returned} = Repos.get_repo(hex.name)
    assert returned.name == hex.name
  end
end
