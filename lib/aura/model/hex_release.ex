# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexRelease do
  @moduledoc Aura.Doc.mod_doc(
               "A struct describing a single release of a `Aura.Model.HexPackage`",
               example: """
               %Aura.Model.HexRelease{
                checksum: "4eaafe67a4b2d3a3b7f4637106ce81707cfa0977e6b3b44450cde4c4626a3c1a",
                configs: %{
                  "erlang.mk" => "dep_aura = hex 0.9.0",
                  "mix.exs" => "{:aura, \"~> 0.9.0\"}",
                  "rebar.config" => "{aura, \"0.9.0\"}"
                },
                docs_html_url: "https://hexdocs.pm/aura/0.9.0/",
                has_docs: true,
                html_url: "https://hex.pm/packages/aura/0.9.0",
                inserted_at: ~U[2025-06-01 15:13:00.595681Z],
                meta: %{elixir: "~> 1.18", app: "aura", build_tools: ["mix"]},
                package_url: "https://hex.pm/api/packages/aura",
                publisher: %{
                  url: "https://hex.pm/api/users/camatcode",
                  username: "camatcode",
                  email: "cam.cook.codes@gmail.com"
                },
                requirements: [
                  %{optional: false, app: "cachex", requirement: "~> 4.0"},
                  %{optional: false, app: "date_time_parser", requirement: "~> 1.2.0"},
                  %{optional: false, app: "proper_case", requirement: "~> 1.3"},
                  %{optional: false, app: "req", requirement: "~> 0.5.10"}
                ],
                retirement: nil,
                updated_at: ~U[2025-06-01 15:13:04.347130Z],
                version: "0.9.0",
                url: "https://hex.pm/api/packages/aura/releases/0.9.0",
                downloads: 15
               }
               """,
               related: [Aura.Packages]
             )

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexRelease

  @typedoc Aura.Doc.type_doc("SHA-256 checksum of the associated release **tar.gz**",
             example: """
               "4eaafe67a4b2d3a3b7f4637106ce81707cfa0977e6b3b44450cde4c4626a3c1a"
             """,
             related: [Aura.Releases]
           )
  @type release_checksum :: String.t()

  @typedoc Aura.Doc.type_doc("A mapping between a build-tool config and the configuration needed to grab this release",
             example: """
                %{
                  "erlang.mk" => "dep_aura = hex 0.9.0",
                  "mix.exs" => "{:aura, \"~> 0.9.0\"}",
                  "rebar.config" => "{aura, \"0.9.0\"}"
                }
             """,
             related: [Aura.Releases]
           )
  @type build_tool_declarations :: map()

  @typedoc Aura.Doc.type_doc("Whether this release has associated docs")
  @type docs? :: boolean()

  @typedoc Aura.Doc.type_doc("Number of all time downloads of this release")
  @type release_downloads :: non_neg_integer()

  @typedoc Aura.Doc.type_doc("URI reference to the `Aura.Model.HexPackage` this release belongs to",
             example: """
             "https://hex.pm/api/packages/aura/releases/0.9.0"
             """,
             related: [Aura.Releases]
           )
  @type package_reference_url :: URI.t()

  @typedoc Aura.Doc.type_doc("Additional information relevant to the release",
             example: """
             %{elixir: "~> 1.18", app: "aura", build_tools: ["mix"]}
             """,
             related: [Aura.Releases]
           )
  @type release_meta :: map()

  @typedoc Aura.Doc.type_doc("Information about the user which published this release",
             example: """
             %{
              url: "https://hex.pm/api/users/camatcode",
              username: "camatcode",
              email: "cam.cook.codes@gmail.com"
             }
             """,
             related: [Aura.Releases]
           )
  @type release_publisher :: map()

  @typedoc Aura.Doc.type_doc("A dependency of this release",
             example: """
             %{optional: false, app: "req", requirement: "~> 0.5.10"}
             """,
             related: [Aura.Releases]
           )
  @type release_requirement :: map()

  @typedoc Aura.Doc.type_doc("Whether this release is considered retired")
  @type retired? :: boolean()

  @typedoc Aura.Doc.type_doc("Type describing a `Aura.Model.HexRelease`",
             keys: %{
               checksum: {Aura.Model.HexRelease, :release_checksum},
               configs: {Aura.Model.HexRelease, :build_tool_declarations},
               docs_html_url: Aura.Model.Common,
               has_docs: {Aura.Model.HexRelease, :docs?},
               meta: {Aura.Model.HexRelease, :release_meta},
               publisher: {Aura.Model.HexRelease, :release_publisher},
               html_url: Aura.Model.Common,
               downloads: {Aura.Model.HexRelease, :release_downloads},
               inserted_at: Aura.Model.Common,
               retirement: {Aura.Model.HexRelease, :retired?},
               package_url: {Aura.Model.HexRelease, :package_reference_url},
               requirements: {Aura.Model.HexRelease, :release_requirement, :list},
               updated_at: Aura.Model.Common,
               url: Aura.Model.Common,
               version: {Aura.Common, :release_version}
             },
             example: """
             %Aura.Model.HexRelease{
              checksum: "4eaafe67a4b2d3a3b7f4637106ce81707cfa0977e6b3b44450cde4c4626a3c1a",
              configs: %{
                "erlang.mk" => "dep_aura = hex 0.9.0",
                "mix.exs" => "{:aura, \"~> 0.9.0\"}",
                "rebar.config" => "{aura, \"0.9.0\"}"
              },
              docs_html_url: "https://hexdocs.pm/aura/0.9.0/",
              has_docs: true,
              html_url: "https://hex.pm/packages/aura/0.9.0",
              inserted_at: ~U[2025-06-01 15:13:00.595681Z],
              meta: %{elixir: "~> 1.18", app: "aura", build_tools: ["mix"]},
              package_url: "https://hex.pm/api/packages/aura",
              publisher: %{
                url: "https://hex.pm/api/users/camatcode",
                username: "camatcode",
                email: "cam.cook.codes@gmail.com"
              },
              requirements: [
                %{optional: false, app: "cachex", requirement: "~> 4.0"},
                %{optional: false, app: "date_time_parser", requirement: "~> 1.2.0"},
                %{optional: false, app: "proper_case", requirement: "~> 1.3"},
                %{optional: false, app: "req", requirement: "~> 0.5.10"}
              ],
              retirement: nil,
              updated_at: ~U[2025-06-01 15:13:04.347130Z],
              version: "0.9.0",
              url: "https://hex.pm/api/packages/aura/releases/0.9.0",
              downloads: 15
              }
             """,
             related: [Aura.Releases]
           )
  @type t :: %HexRelease{
          checksum: release_checksum(),
          configs: build_tool_declarations(),
          docs_html_url: Common.docs_html_url(),
          has_docs: docs?(),
          meta: release_meta(),
          publisher: release_publisher(),
          html_url: Common.html_url(),
          downloads: release_downloads(),
          inserted_at: Common.inserted_at(),
          retirement: retired?(),
          package_url: package_reference_url(),
          requirements: [release_requirement()],
          updated_at: Common.updated_at(),
          url: Common.url(),
          version: Aura.Common.release_version()
        }

  defstruct [
    :checksum,
    :configs,
    :docs_html_url,
    :has_docs,
    :html_url,
    :inserted_at,
    :meta,
    :package_url,
    :publisher,
    :requirements,
    :retirement,
    :updated_at,
    :version,
    :url,
    downloads: 0
  ]

  @doc Aura.Doc.func_doc("Builds a `HexRelease` from a map",
         params: %{m: "A map to build into a `t:Aura.Model.HexRelease.t/0`"}
       )
  @spec build(m :: map) :: HexRelease.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> Map.new(fn {k, v} -> {k, serialize(k, v)} end)
    |> Enum.reject(fn {_k, v} -> v == nil end)
    |> then(&struct(HexRelease, &1))
  end

  defp serialize(_k, nil), do: nil
  defp serialize(:meta, v), do: v |> prepare() |> Map.new()
  defp serialize(:publisher, v), do: v |> prepare() |> Map.new()
  defp serialize(:downloads, []), do: 0

  defp serialize(:requirements, v) do
    v
    |> Map.values()
    |> Enum.map(fn m -> m |> prepare() |> Map.new() end)
  end

  defp serialize(:retirement, v) do
    v
    |> prepare()
    |> Map.new(fn {k, v} -> if k == :reason, do: {k, String.to_atom(v)}, else: {k, v} end)
  end

  defp serialize(_k, v), do: v
end
