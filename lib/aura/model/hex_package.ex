# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexPackage do
  @moduledoc """
  A struct describing a package from a Hex-compliant API

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  %Aura.Model.HexPackage{
   name: "aura",
   repository: "hexpm",
   private: nil,
   meta: %Aura.Model.HexPackageMeta{
     maintainers: [],
     links: %{
       "Changelog" => "https://github.com/camatcode/aura/blob/master/CHANGELOG.md",
       "GitHub" => "https://github.com/camatcode/aura",
       "Website" => "https://github.com/camatcode/aura"
     },
     licenses: ["Apache-2.0"],
     description: "An ergonomic library for investigating the Hex.pm API"
   },
   downloads: %Aura.Model.HexPackageDownloadStats{all: 4, week: 4, day: 4},
   releases: [
     %Aura.Model.HexRelease{
       has_docs: true,
       inserted_at: ~U[2025-06-01 15:13:00.595681Z],
       version: "0.9.0",
       url: "https://hex.pm/api/packages/aura/releases/0.9.0",
       downloads: 0
     }
   ],
   inserted_at: ~U[2025-06-01 15:13:00.589838Z],
   updated_at: ~U[2025-06-01 15:13:04.347899Z],
   url: "https://hex.pm/api/packages/aura",
   html_url: "https://hex.pm/packages/aura",
   docs_html_url: "https://hexdocs.pm/aura/"
  }
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Releases`"])}

  #{Aura.Doc.resources()}
  <!-- tabs-close -->
  """

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexPackage
  alias Aura.Model.HexPackageDownloadStats
  alias Aura.Model.HexPackageMeta
  alias Aura.Model.HexRelease

  @typedoc """
  The repository a package belongs to

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "hexpm"
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Releases`"])}

  <!-- tabs-close -->
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
    * **name** :: `t:Aura.Common.package_name/0`
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

  ### 💻 Examples

  ```elixir
  %Aura.Model.HexPackage{
   name: "aura",
   repository: "hexpm",
   private: nil,
   meta: %Aura.Model.HexPackageMeta{
     maintainers: [],
     links: %{
       "Changelog" => "https://github.com/camatcode/aura/blob/master/CHANGELOG.md",
       "GitHub" => "https://github.com/camatcode/aura",
       "Website" => "https://github.com/camatcode/aura"
     },
     licenses: ["Apache-2.0"],
     description: "An ergonomic library for investigating the Hex.pm API"
   },
   downloads: %Aura.Model.HexPackageDownloadStats{all: 4, week: 4, day: 4},
   releases: [
     %Aura.Model.HexRelease{
       has_docs: true,
       inserted_at: ~U[2025-06-01 15:13:00.595681Z],
       version: "0.9.0",
       url: "https://hex.pm/api/packages/aura/releases/0.9.0",
       downloads: 0
     }
   ],
   inserted_at: ~U[2025-06-01 15:13:00.589838Z],
   updated_at: ~U[2025-06-01 15:13:04.347899Z],
   url: "https://hex.pm/api/packages/aura",
   html_url: "https://hex.pm/packages/aura",
   docs_html_url: "https://hexdocs.pm/aura/"
  }
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Releases`"])}

  <!-- tabs-close -->
  """
  @type t :: %HexPackage{
          name: Aura.Common.package_name(),
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

  <!-- tabs-open -->

  ### 🏷️ Params
    * **m** :: A map to build into a `t:Aura.Model.HexPackage.t/0`

  <!-- tabs-close -->
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
