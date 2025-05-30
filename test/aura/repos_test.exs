defmodule Aura.ReposTest do
  use ExUnit.Case

  alias Aura.Repos

  @moduletag :capture_log
  doctest Repos

  setup do
    TestHelper.setup_state()
  end

  test "list_repos", _state do
    # use Hex.pm
    assert {:ok, [%{name: "hexpm"}]} = Repos.list_repos()

    # use another repo URL
    mock_repo = TestHelper.get_mock_repo()
    assert {:ok, [%{name: "acme"}]} = Repos.list_repos(repo_url: mock_repo)
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

  test "get_repo/1", _state do
    # use hex.pm
    assert {:ok, [hex]} = Repos.list_repos()
    assert {:ok, returned} = Repos.get_repo(hex.name)
    assert returned.name == hex.name

    # use another repo URL
    mock_repo = TestHelper.get_mock_repo()
    assert {:ok, [hex]} = Repos.list_repos(repo_url: mock_repo)
    assert {:ok, returned} = Repos.get_repo(hex.name, repo_url: mock_repo)
    assert returned.name == hex.name
  end
end
