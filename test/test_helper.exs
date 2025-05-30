ExUnit.configure(formatters: [JUnitFormatter, ExUnit.CLIFormatter])
{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start(timeout: 2 * 60 * 1000)

defmodule TestHelper do
  @moduledoc false
  use ExUnit.Case

  alias Aura.Packages
  alias Aura.PackageTarUtil
  alias Aura.Releases
  alias Aura.Repos
  alias Aura.Users

  require Logger

  @moduletag :capture_log

  def setup_state do
    repo_url = validate_repo_url()
    password = Faker.Internet.slug() <> "#{System.monotonic_time()}"
    Application.delete_env(:aura, :api_key)
    # Create a user
    {user, other_users} = create_users(repo_url, password)
    # Create an write API key
    api_key = create_api_key(user, password)
    # Generate some package and releases
    {owned_packages, owned_releases} = create_releases()

    %{
      user: user,
      other_users: other_users,
      api_key: api_key,
      owned_releases: owned_releases,
      owned_packages: owned_packages
    }
  end

  defp validate_repo_url do
    repo_url = Application.get_env(:aura, :repo_url)

    if repo_url == nil || repo_url |> String.downcase() |> String.contains?("hex.pm") do
      raise "Don't test against hex.pm!"
    end

    repo_url
  end

  defp create_users(repo_url, password) do
    username = Faker.Internet.user_name()
    email = Faker.Internet.email()
    {:ok, user} = Users.create_user(username, password, email)

    other_users =
      Enum.map(1..5, fn _ ->
        {:ok, other_user} = Users.create_user("#{username}_#{System.monotonic_time()}", password, Faker.Internet.email())
        other_user
      end)

    verify_emails(repo_url)
    {user, other_users}
  end

  defp create_api_key(user, password) do
    api_key_name = Faker.Internet.slug()
    {:ok, api_key} = Repos.create_api_key(api_key_name, user.username, password, true)
    Application.put_env(:aura, :api_key, api_key.secret)
    api_key
  end

  defp create_releases do
    %{packages: owned_packages, releases: owned_releases} =
      1..5
      |> Enum.map(fn _ ->
        github_url = Faker.Internet.url()

        package_name =
          (Faker.App.name() <> "#{System.monotonic_time()}")
          |> String.replace(" ", "_")
          |> String.replace("-", "_")
          |> String.downcase()

        release_version = Faker.App.semver()
        description = Faker.Lorem.sentence()
        {:ok, new_tar} = generate_release_tar(package_name, release_version, description, github_url)

        {:ok, _} = Releases.publish_release(new_tar)
        path = Path.join("test/support/data/docs/", "nimble_parsec-1.4.2.tar.gz")
        {:ok, _} = Releases.publish_release_docs(package_name, release_version, path)
        {:ok, release} = Releases.get_release(package_name, release_version)
        {:ok, package} = Packages.get_package(package_name)
        {package, release}
      end)
      |> Enum.reduce(%{packages: [], releases: []}, fn {package, release}, acc ->
        new_packages = Map.get(acc, :packages) ++ [package]
        new_releases = Map.get(acc, :releases) ++ [release]
        %{packages: new_packages, releases: new_releases}
      end)

    {owned_packages, owned_releases}
  end

  def generate_release_tar(package_name, release_version, description, github_url) do
    path = Path.join("test/support/data/release/", "nimble_parsec-1.4.2.tar")
    {:ok, datas} = PackageTarUtil.read_release_tar(path)
    contents_tar_gz = datas[:"contents.tar.gz"]
    tar_version = datas[:VERSION]

    new_metadata_config =
      :binary.bin_to_list(generate_metadata_config(package_name, release_version, description, github_url))

    new_checksum =
      :sha256
      |> :crypto.hash(tar_version ++ new_metadata_config ++ contents_tar_gz)
      |> Base.encode16(case: :upper)

    new_tar_name =
      package_name <> "-" <> release_version <> ".tar"

    tmp_dir = Path.join(System.tmp_dir!(), "#{package_name}/")

    :ok = File.mkdir_p!(tmp_dir)
    on_exit(fn -> File.rm_rf(tmp_dir) end)

    :ok = File.write!(Path.join(tmp_dir, "metadata.config"), new_metadata_config)
    :ok = File.write!(Path.join(tmp_dir, "VERSION"), tar_version)
    :ok = File.write!(Path.join(tmp_dir, "CHECKSUM"), new_checksum)
    :ok = File.write!(Path.join(tmp_dir, "contents.tar.gz"), contents_tar_gz)

    :ok =
      tmp_dir
      |> Path.join(new_tar_name)
      |> :erl_tar.create(
        Enum.map(
          [
            {"metadata.config", Path.join(tmp_dir, "metadata.config")},
            {"VERSION", Path.join(tmp_dir, "VERSION")},
            {"CHECKSUM", Path.join(tmp_dir, "CHECKSUM")},
            {"contents.tar.gz", Path.join(tmp_dir, "contents.tar.gz")}
          ],
          fn {name, path} -> {to_charlist(name), to_charlist(path)} end
        )
      )

    {:ok, Path.join(tmp_dir, new_tar_name)}
  end

  defp generate_metadata_config(package_name, release_version, description, github_url) do
    path = Path.join("test/support/data/release/", "metadata.config.template")
    template = File.read!(path)

    template
    |> String.replace("GITHUB_URL", github_url)
    |> String.replace("PACKAGE_NAME", package_name)
    |> String.replace("RELEASE_VERSION", release_version)
    |> String.replace("PACKAGE_DESCRIPTION", description)
  end

  defp verify_emails(repo_url) do
    :timer.sleep(10)
    base_url = String.replace(repo_url, "/api", "")
    sent_email_url = Path.join(base_url, "/sent_emails")

    with {:ok, %{status: 200, body: body}} <- Req.get(sent_email_url) do
      urls = body |> String.split("\n") |> Enum.filter(&String.starts_with?(&1, base_url))

      Enum.map(urls, fn url ->
        decoded = String.replace(url, "amp;", "")
        Req.get(decoded, redirect: false)
      end)
    end
  end
end
