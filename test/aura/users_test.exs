defmodule Aura.UsersTest do
  use ExUnit.Case

  alias Aura.Packages
  alias Aura.Users

  doctest Users
  @moduletag :capture_log

  test "get user" do
    # use hex
    packages = Enum.take(Packages.list_packages(), 5)
    refute Enum.empty?(packages)

    Enum.each(packages, fn package ->
      {:ok, owners} = Packages.list_package_owners(package.name)
      refute Enum.empty?(owners)

      Enum.each(owners, fn owner ->
        assert {:ok, user} = Users.get_user(owner.username)
        assert user.username
        assert user.inserted_at
        assert user.updated_at
        assert user.url
      end)
    end)
  end

  test "create user" do
    # use another repo
    mock_repo = TestHelper.get_mock_repo()
    Application.put_env(:aura, :repo_url, mock_repo)
    username = Faker.Internet.user_name()
    email = Faker.Internet.email()
    password = Faker.Internet.slug()

    # See: https://github.com/hexpm/specifications/issues/41
    assert {:ok, _} = Users.create_user(username, email, password, raw: true)
    Application.delete_env(:aura, :repo_url)
  end
end
