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
    assert release.checksum

    assert {:ok, release} = Releases.get_release("ex_ftp", "0.9.2")
    assert release.retirement.message
  end
end
