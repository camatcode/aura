# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexPackageMeta do
  @moduledoc """
  A struct describing additional metadata about a `Aura.Model.HexPackage`
  """

  import Aura.Model.Common

  alias Aura.Model.HexPackageMeta

  @typedoc """
  Additional external URL relating to the package
  """
  @type meta_url :: URI.t()

  @typedoc """
  The software license associated to the package
  """
  @type software_license :: String.t()

  @typedoc """
  Short, human-readable description of the package
  """
  @type package_description :: String.t()

  @typedoc """
  Type describing additional metadata about a `Aura.Model.HexPackage`

  <!-- tabs-open -->
  ### 🏷️ Keys
    * **maintainers** :: [`t:Aura.Model.Common.username/0`]
    * **links** ::  [`t:meta_url/0`]
    * **licenses** :: [`t:software_license/0`]
    * **description** :: `t:package_description/0`

  <!-- tabs-close -->
  """
  @type t :: %HexPackageMeta{
          maintainers: [Aura.Model.Common.username()],
          links: [meta_url()],
          licenses: [software_license()],
          description: package_description()
        }

  defstruct [
    :maintainers,
    :links,
    :licenses,
    :description
  ]

  @doc """
  Builds a `HexPackageMeta` from a map
  """
  @spec build(m :: map) :: HexPackageMeta.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&struct(HexPackageMeta, &1))
  end
end
