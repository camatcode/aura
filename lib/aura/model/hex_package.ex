# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexPackage do
  @moduledoc Aura.Doc.mod_doc(
               "A struct describing a package from a Hex-compliant API",
               example: """
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
               """,
               related: [Aura.Packages, Aura.Releases]
             )

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexPackage
  alias Aura.Model.HexPackageDownloadStats
  alias Aura.Model.HexPackageMeta
  alias Aura.Model.HexRelease

  @typedoc Aura.Doc.type_doc("Whether this package is publicly available")
  @type private? :: boolean

  @typedoc Aura.Doc.type_doc("Type describing a package from a Hex-compliant API",
             keys: %{
               name: {Aura.Common, :package_name},
               repository: {Aura.Common, :repo_name},
               private: {Aura.Model.HexPackage, :private?},
               meta: {Aura.Model.HexPackageMeta, :t},
               downloads: {Aura.Model.HexPackageDownloadStats, :t},
               releases: {Aura.Model.HexRelease, :t, :list},
               inserted_at: Aura.Model.Common,
               updated_at: Aura.Model.Common,
               url: Aura.Model.Common,
               html_url: Aura.Model.Common,
               docs_html_url: Aura.Model.Common
             },
             example: """
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
             """,
             related: [Aura.Packages, Aura.Releases]
           )
  @type t :: %HexPackage{
          name: Aura.Common.package_name(),
          repository: Aura.Common.repo_name(),
          private: private?(),
          meta: HexPackageMeta.t(),
          downloads: HexPackageDownloadStats.t(),
          releases: [HexRelease.t()],
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

  @doc Aura.Doc.func_doc("Builds a `HexPackage` from a map",
         params: %{m: "A map to build into a `t:Aura.Model.HexPackage.t/0`"}
       )
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
