defmodule Aura.UsersTest do
  use ExUnit.Case

  alias Aura.Packages
  alias Aura.Users

  doctest Users
  @moduletag :capture_log

  setup do
    TestHelper.setup_state()
  end

  test "get user", _state do
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

  test "create user", %{user: user} do
    assert user
  end

  test "get current user", %{user: user} do
    {:ok, ^user} = Users.get_current_user()
  end

  test "reset user password", %{user: user} do
    assert :ok = Users.reset_user_password(user.username)
  end
end
