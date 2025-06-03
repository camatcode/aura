defmodule Aura.PackagesTest do
  @moduledoc false

  use ExUnit.Case

  alias Aura.Packages

  @moduletag :capture_log
  doctest Aura.Packages

  setup do
    TestHelper.setup_state()
  end

  #  test "connection-to-hex" do
  #    Application.delete_env(:aura, :repo_url)
  #    Application.delete_env(:aura, :api_key)
  #    "decimal" |> Packages.get_package() |> IO.inspect()
  #    # "aura" |> Packages.list_package_owners() |> IO.inspect()
  #    #    "aura" |> Aura.Releases.get_release("0.9.0") |> IO.inspect()
  #  end

  test "package search", _state do
    [search: "ups", sort: :recent_downloads]
    |> Packages.stream_packages()
    |> Enum.each(fn package ->
      assert String.contains?(package.name, "ups")
    end)
  end

  test "stream_packages", _state do
    # First 2000
    first_2k = Enum.take(Packages.stream_packages(sort: :recent_downloads), 2000)
    assert Enum.count(first_2k) <= 2000

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
      [page: 25, sort: :recent_downloads]
      |> Packages.stream_packages()
      |> Enum.take(200)

    assert Enum.count(page_25_forward) <= 200

    Enum.each(page_25_forward, fn package ->
      assert package.name
      assert package.repository
      assert package.url
      refute Enum.member?(first_2k, package)
    end)
  end

  test "list_package_owners", _state do
    packages = Enum.take(Packages.stream_packages(sort: :recent_downloads), 100)
    refute Enum.empty?(packages)

    Enum.each(packages, fn package ->
      {:ok, owners} = Packages.list_package_owners(package.name)
      refute Enum.empty?(owners)

      Enum.each(owners, fn owner ->
        assert owner.username
        assert owner.level
        assert owner.url

        assert {:ok, ^owner} = Packages.get_package_owner(package.name, owner.username)
      end)
    end)
  end

  test "get_package", _state do
    packages = Enum.take(Packages.stream_packages(sort: :recent_downloads), 100)
    refute Enum.empty?(packages)

    Enum.each(packages, fn package ->
      assert {:ok, retrieved} = Packages.get_package(package.name)
      assert package == retrieved
    end)
  end

  test "stream_audit_logs", %{owned_packages: packages} do
    Enum.each(packages, fn package ->
      package.name
      |> Packages.stream_audit_logs()
      |> Enum.each(fn audit_log ->
        assert audit_log.params
        assert audit_log.action
        assert audit_log.user_agent
      end)
    end)
  end

  test "add / remove package owners", %{other_users: [other_user | _], owned_packages: owned_packages} do
    Enum.each(owned_packages, fn package ->
      assert :ok = Packages.add_package_owner(package.name, other_user.email)
      assert :ok = Packages.remove_package_owner(package.name, other_user.email)
    end)
  end
end
