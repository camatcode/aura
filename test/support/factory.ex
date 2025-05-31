# coveralls-ignore-start
defmodule Aura.Factory do
  @moduledoc false
  use ExMachina
  use Aura.Factory.HexRepoFactory
  use Aura.Factory.HexPackageFactory
  use Aura.Factory.HexPackageOwnerFactory
  use Aura.Factory.HexReleaseFactory
  use Aura.Factory.HexAPIKeyFactory
  use Aura.Factory.HexUserFactory
end

# coveralls-ignore-stop
