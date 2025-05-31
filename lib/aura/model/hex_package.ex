# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexPackage do
  @moduledoc """
  A struct describing a package from a Hex-compliant API
  """

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexPackage
  alias Aura.Model.HexPackageDownloadStats
  alias Aura.Model.HexPackageMeta
  alias Aura.Model.HexRelease

  @typedoc """
  Name of the package (e.g `"plug"`)
  """
  @type package_name :: String.t()

  @typedoc """
  The repository the package belongs to (e.g `"hexpm"`)
  """
  @type repository :: String.t()

  @typedoc """
  Whether this package is publicly available
  """
  @type private? :: boolean

  @typedoc """
  Type describing a package from a Hex-compliant API

  <!-- tabs-open -->
  ### 🏷️ Keys
    * **name** :: `t:package_name/0`
    * **repository** :: `t:repository/0`
    * **private** :: `t:private?/0`
    * **meta** :: `t:Aura.Model.HexPackageMeta.t/0`
    * **downloads** :: `t:Aura.Model.HexPackageDownloadStats.t/0`
    * **releases** :: `t:map/0`
    * **inserted_at** :: `t:Aura.Model.Common.inserted_at/0`
    * **updated_at** :: `t:Aura.Model.Common.updated_at/0`
    * **url** :: `t:Aura.Model.Common.url/0`
    * **html_url** :: `t:Aura.Model.Common.html_url/0`
    * **docs_html_url** :: `t:Aura.Model.Common.docs_html_url/0`

  <!-- tabs-close -->
  """
  @type t :: %HexPackage{
          name: package_name(),
          repository: repository(),
          private: private?(),
          meta: HexPackageMeta.t(),
          downloads: HexPackageDownloadStats.t(),
          releases: map(),
          inserted_at: Common.inserted_at(),
          updated_at: Common.updated_at(),
          url: Common.url(),
          html_url: Common.html_url(),
          docs_html_url: Common.docs_html_url()
        }

  defstruct [
    :name,
    :repository,
    :private,
    :meta,
    :downloads,
    :releases,
    :inserted_at,
    :updated_at,
    :url,
    :html_url,
    :docs_html_url
  ]

  @doc """
  Builds a `HexPackage` from a map
  """
  @spec build(m :: map) :: HexPackage.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> Enum.map(fn {k, v} -> {k, serialize(k, v)} end)
    |> then(&struct(HexPackage, &1))
  end

  defp serialize(_k, nil), do: nil
  defp serialize(:meta, v), do: HexPackageMeta.build(v)
  defp serialize(:downloads, v), do: HexPackageDownloadStats.build(v)
  defp serialize(:releases, v), do: Enum.map(v, &HexRelease.build/1)
  defp serialize(_k, v), do: v
end
