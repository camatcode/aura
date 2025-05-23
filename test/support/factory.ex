defmodule Aura.Factory do
  @moduledoc false
  use ExMachina
  use Aura.Factory.HexRepoFactory
  use Aura.Factory.HexPackageFactory
  use Aura.Factory.HexReleaseFactory
end
