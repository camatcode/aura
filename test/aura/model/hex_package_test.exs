defmodule Aura.Model.HexPackageTest do
  use ExUnit.Case

  import Aura.Factory

  alias Aura.Model.HexPackage

  doctest HexPackage

  test "build many" do
    list = build_list(100, :hex_package)
    assert Enum.count(list) == 100
  end
end
