defmodule Aura.Model.HexAPIKeyTest do
  use ExUnit.Case

  import Aura.Factory

  alias Aura.Model.HexAPIKey

  @moduletag :capture_log

  doctest HexAPIKey

  test "build many" do
    list = build_list(100, :hex_api_key)
    assert Enum.count(list) == 100
  end
end
