defmodule Aura.ReleasesTest do
  use ExUnit.Case

  alias Aura.Packages
  alias Aura.Releases

  @moduletag :capture_log

  doctest Releases

  test "get_release" do
    [package] = Enum.take(Packages.list_packages(), 1)
    version = package.releases |> hd() |> Map.get(:version)
    assert {:ok, release} = Releases.get_release(package.name, version)
    assert release.publisher

    assert {:ok, release} = Releases.get_release("ex_ftp", "0.9.2")
    assert release.retirement.message
  end

  test "retire/un-retire release" do
    mock_repo = TestHelper.get_mock_repo()
    api_key = TestHelper.get_mock_api_key()
    Application.put_env(:aura, :api_key, api_key)
    Application.put_env(:aura, :repo_url, mock_repo)
    [package] = Enum.take(Packages.list_packages(), 1)
    version = package.releases |> hd() |> Map.get(:version)
    reason = :deprecated
    message = "This package has been deprecated in favor of ecto."
    assert :ok = Releases.retire_release(package.name, version, reason, message)

    assert :ok = Releases.undo_retire_release(package.name, version)

    Application.delete_env(:aura, :repo_url)
    Application.delete_env(:aura, :api_key)
  end

  test "delete_release_docs" do
    # use mock repo
    mock_repo = TestHelper.get_mock_repo()
    api_key = TestHelper.get_mock_api_key()
    Application.put_env(:aura, :api_key, api_key)
    Application.put_env(:aura, :repo_url, mock_repo)
    [package] = Enum.take(Packages.list_packages(), 1)
    version = package.releases |> hd() |> Map.get(:version)
    assert :ok = Releases.delete_release_docs(package.name, version)

    Application.delete_env(:aura, :repo_url)
    Application.delete_env(:aura, :api_key)
  end
end
