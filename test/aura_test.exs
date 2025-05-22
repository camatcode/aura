defmodule AuraTest do
  use ExUnit.Case

  doctest Aura

  test "greets the world" do
    assert Aura.hello() == :world
  end
end
