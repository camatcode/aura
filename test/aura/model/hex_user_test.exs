defmodule Aura.Model.HexUserTest do
  use ExUnit.Case

  import Aura.Factory

  alias Aura.Model.HexUser

  @moduletag :capture_log

  doctest HexUser

  test "build_many" do
    list = build_list(100, :hex_user)
    assert Enum.count(list) == 100
  end
end
