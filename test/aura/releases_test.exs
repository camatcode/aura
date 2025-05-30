defmodule Aura.ReleasesTest do
  use ExUnit.Case

  alias Aura.Packages
  alias Aura.Releases

  @moduletag :capture_log

  doctest Releases

  setup do
    TestHelper.setup_state()
  end

  test "get_release", %{owned_releases: owned_releases, owned_packages: owned_packages} do
    [package] = Enum.take(Packages.list_packages(), 1)
    version = package.releases |> hd() |> Map.get(:version)
    assert {:ok, release} = Releases.get_release(package.name, version)
    assert release.publisher

    Enum.each(owned_packages, fn package ->
      version = package.releases |> hd() |> Map.get(:version)
      assert {:ok, release} = Releases.get_release(package.name, version)
      assert hd(owned_releases) == release
    end)
  end

  test "retire/un-retire release", %{owned_packages: owned_packages} do
    Enum.each(owned_packages, fn package ->
      version = package.releases |> hd() |> Map.get(:version)
      reason = :deprecated
      message = "This package has been deprecated in favor of ecto."
      assert :ok = Releases.retire_release(package.name, version, reason, message)
      assert :ok = Releases.undo_retire_release(package.name, version)
    end)
  end

  test "delete_release_docs", %{owned_packages: owned_packages} do
    Enum.each(owned_packages, fn package ->
      version = package.releases |> hd() |> Map.get(:version)
      assert :ok = Releases.delete_release_docs(package.name, version)
    end)
  end
end
