defmodule Aura.ReleasesTest do
  use ExUnit.Case

  alias Aura.Packages
  alias Aura.Releases
  alias Aura.Repos

  @moduletag :capture_log

  doctest Releases

  setup do
    TestHelper.setup_state()
  end

  test "publish to particular repo", _state do
    {:ok, repos} = Repos.list_repos()

    Enum.each(repos, fn repo ->
      github_url = Faker.Internet.url()

      package_name =
        (Faker.App.name() <> "#{System.monotonic_time()}")
        |> String.replace(" ", "_")
        |> String.replace("-", "_")
        |> String.downcase()

      release_version = Faker.App.semver()
      description = Faker.Lorem.sentence()
      requirements = ""

      {:ok, new_tar} =
        TestHelper.generate_release_tar(package_name, release_version, description, requirements, github_url)

      {:ok, _} = Releases.publish_release(new_tar, repo: repo.name)

      doc_tar = Path.join("test/support/data/docs/", "nimble_parsec-1.4.2.tar.gz")
      {:ok, _} = Releases.publish_release_docs(package_name, release_version, doc_tar, repo: repo.name)

      :ok = Releases.delete_release(package_name, release_version)
    end)
  end

  test "get_release", %{owned_releases: owned_releases, owned_packages: owned_packages} do
    [package] = Enum.take(Packages.stream_packages(sort: :recent_downloads), 1)
    version = package.releases |> hd() |> Map.get(:version)
    assert {:ok, release} = Releases.get_release(package.name, version)
    assert release.publisher

    # investigating requirements
    {:ok, postgresx} = Releases.get_release("postgrex", "0.1.0")
    assert postgresx.requirements == [%{optional: false, app: "decimal", requirement: "0.1.0"}]

    Enum.each(owned_packages, fn package ->
      version = package.releases |> hd() |> Map.get(:version)
      assert {:ok, release} = Releases.get_release(package.name, version)
      refute Enum.empty?(release.requirements)
      assert Enum.member?(owned_releases, release)
    end)
  end

  test "retire/un-retire release", %{owned_packages: owned_packages} do
    Enum.each(owned_packages, fn package ->
      version = package.releases |> hd() |> Map.get(:version)
      reason = :not_a_valid_reason
      message = "This package has been deprecated in favor of ecto."
      assert :ok = Releases.retire_release(package.name, version, reason, message)

      {:ok, %{retirement: %{message: ^message, reason: :other}}} =
        Releases.get_release(package.name, version)

      assert :ok = Releases.undo_retire_release(package.name, version)

      {:ok, release} = Releases.get_release(package.name, version)
      refute release.retirement

      assert :ok = Releases.retire_release(package.name, version, :deprecated, message)
      assert :ok = Releases.undo_retire_release(package.name, version)
      assert :ok = Releases.retire_release(package.name, version, "deprecated", message)

      {:ok, %{retirement: %{message: ^message, reason: :deprecated}}} =
        Releases.get_release(package.name, version)
    end)
  end

  test "delete_release_docs", %{owned_packages: owned_packages} do
    Enum.each(owned_packages, fn package ->
      version = package.releases |> hd() |> Map.get(:version)
      # test env will never return release docs
      _ = Releases.get_release_docs(package.name, version)
      assert :ok = Releases.delete_release_docs(package.name, version)
    end)
  end
end
