defmodule Aura.ReposTest do
  use ExUnit.Case

  alias Aura.Repos

  doctest Repos

  test "list_repos" do
    # use Hex.pm
    assert {:ok, [%{name: "hexpm"}]} = Repos.list_repos()

    # use another repo URL
    mock_repo = TestHelper.get_mock_repo()
    assert {:ok, [%{name: "acme"}]} = Repos.list_repos(repo_url: mock_repo)
  end

  test "api_keys" do
    # use another repo
    mock_repo = TestHelper.get_mock_repo()
    api_key = TestHelper.get_mock_api_key()
    Application.put_env(:aura, :api_key, api_key)
    Application.put_env(:aura, :repo_url, mock_repo)

    assert {:ok, [api_key]} = Repos.list_api_keys()
    assert api_key.authing_key
    assert api_key.inserted_at
    assert api_key.updated_at
    assert api_key.name
    assert api_key.url

    assert {:ok, retrieved} = Repos.get_api_key(api_key.name)
    assert retrieved.name == api_key.name

    assert :ok = Repos.delete_api_key(api_key.name)

    Application.delete_env(:aura, :repo_url)
    Application.delete_env(:aura, :api_key)
  end

  test "get_repo/1" do
    # use hex.pm
    assert {:ok, [hex]} = Repos.list_repos()
    assert {:ok, returned} = Repos.get_repo(hex.name)
    assert returned.name == hex.name

    # use another repo
    # use another repo URL
    mock_repo = TestHelper.get_mock_repo()
    assert {:ok, [hex]} = Repos.list_repos(repo_url: mock_repo)
    assert {:ok, returned} = Repos.get_repo(hex.name, repo_url: mock_repo)
    assert returned.name == hex.name
  end
end
