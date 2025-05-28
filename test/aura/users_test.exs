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
end
