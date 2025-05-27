defmodule Aura.Model.HexPackageOwnerTest do
  use ExUnit.Case

  import Aura.Factory

  alias Aura.Model.HexPackageOwner

  @moduletag :capture_log

  doctest HexPackageOwner

  test "build many" do
    list = build_list(100, :hex_package_owner)
    assert Enum.count(list) == 100
  end
end
