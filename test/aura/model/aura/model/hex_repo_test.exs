defmodule Aura.Model.HexRepoTest do
  use ExUnit.Case

  import Aura.Factory

  alias Aura.Model.HexRepo

  @moduletag :capture_log

  doctest HexRepo

  test "build_many" do
    list = build_list(100, :hex_repo)
    assert Enum.count(list) == 100
  end
end
