defmodule Aura.Model.HexReleaseTest do
  use ExUnit.Case

  import Aura.Factory

  alias Aura.Model.HexRelease

  @moduletag :capture_log
  doctest HexRelease

  test "build many" do
    list = build_list(100, :hex_release)
    assert Enum.count(list) == 100
  end
end
