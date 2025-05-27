defmodule Aura.PackagesTest do
  @moduledoc false

  use ExUnit.Case

  alias Aura.Packages

  doctest Aura.Packages

  test "list_packages" do
    # First 2000
    first_2k = Enum.take(Packages.list_packages(), 2000)
    assert Enum.count(first_2k) == 2000

    Enum.each(first_2k, fn package ->
      assert package.name
      assert package.repository
      assert package.url
      assert package.meta
      assert package.downloads
      assert package.releases
    end)

    # Page 25 onward
    page_25_forward =
      [page: 25]
      |> Packages.list_packages()
      |> Enum.take(200)

    assert Enum.count(page_25_forward) == 200

    Enum.each(page_25_forward, fn package ->
      assert package.name
      assert package.repository
      assert package.url
      refute Enum.member?(first_2k, package)
    end)
  end

  test "list_package_owners" do
    packages = Enum.take(Packages.list_packages(), 100)
    refute Enum.empty?(packages)

    Enum.each(packages, fn package ->
      {:ok, owners} = Packages.list_package_owners(package.name)
      refute Enum.empty?(owners)

      Enum.each(owners, fn owner ->
        assert owner.username
        assert owner.level
        assert owner.url
      end)
    end)
  end

  test "get_package" do
    packages = Enum.take(Packages.list_packages(), 100)
    refute Enum.empty?(packages)

    Enum.each(packages, fn package ->
      assert {:ok, retrieved} = Packages.get_package(package.name)
      assert package == retrieved
    end)
  end
end
