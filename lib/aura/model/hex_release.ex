# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexRelease do
  @moduledoc """
  A struct describing a single release of a `Aura.Model.HexPackage`

  <!-- tabs-open -->
  ### 💻 Examples

  ```elixir
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
  ```

  #{Aura.Doc.related(["`Aura.Releases`"])}

  #{Aura.Doc.resources()}
  <!-- tabs-close -->
  """

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexRelease

  @typedoc """
  SHA-256 checksum of the associated release **tar.gz**

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "4eaafe67a4b2d3a3b7f4637106ce81707cfa0977e6b3b44450cde4c4626a3c1a"
  ```

  #{Aura.Doc.related(["`Aura.Releases`"])}

  <!-- tabs-close -->
  """
  @type release_checksum :: String.t()

  @typedoc """
  A mapping between a build-tool config and the configuration needed to grab this release

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  %{
     "erlang.mk" => "dep_aura = hex 0.9.0",
     "mix.exs" => "{:aura, \"~> 0.9.0\"}",
     "rebar.config" => "{aura, \"0.9.0\"}"
  }
  ```

  #{Aura.Doc.related(["`Aura.Releases`"])}

  <!-- tabs-close -->
  """
  @type build_tool_declarations :: map()

  @typedoc """
  Whether this release has associated docs
  """
  @type docs? :: boolean()

  @typedoc """
  Number of all time downloads of this release
  """
  @type release_downloads :: non_neg_integer()

  @typedoc """
  URI reference to the `Aura.Model.HexPackage` this release belongs to

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "https://hex.pm/api/packages/aura/releases/0.9.0"
  ```

  #{Aura.Doc.related(["`Aura.Releases`"])}

  <!-- tabs-close -->
  """
  @type package_reference_url :: URI.t()

  @typedoc """
  Additional information relevant to the release

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  %{elixir: "~> 1.18", app: "aura", build_tools: ["mix"]}
  ```

  #{Aura.Doc.related(["`Aura.Releases`"])}

  <!-- tabs-close -->
  """
  @type release_meta :: map()

  @typedoc """
  Information about the user which published this release

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  %{
     url: "https://hex.pm/api/users/camatcode",
     username: "camatcode",
     email: "cam.cook.codes@gmail.com"
   }
  ```

  #{Aura.Doc.related(["`Aura.Releases`"])}

  <!-- tabs-close -->
  """
  @type release_publisher :: map()

  @typedoc """
  A dependency of this release

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  %{optional: false, app: "req", requirement: "~> 0.5.10"}
  ```

  #{Aura.Doc.related(["`Aura.Releases`"])}

  <!-- tabs-close -->
  """
  @type release_requirement :: map()

  @typedoc """
  Whether this release is considered retired
  """
  @type retired? :: boolean()

  @typedoc """
  Type describing a `Aura.Model.HexRelease`

  <!-- tabs-open -->
  ### 🏷️ Keys
    * **checksum** :: `t:release_checksum/0`
    * **configs** ::  `t:build_tool_declarations/0`
    * **docs_html_url** :: `t:Aura.Model.Common.docs_html_url/0`
    * **has_docs** :: `t:docs?/0`
    * **meta** :: `t:release_meta/0`
    * **publisher** :: `t:release_publisher/0`
    * **html_url** :: `t:Aura.Model.Common.html_url/0`
    * **downloads** :: `t:release_downloads/0`
    * **inserted_at** :: `t:Aura.Model.Common.inserted_at/0`
    * **retirement** :: `t:retired?/0`
    * **package_url** :: `t:package_reference_url/0`
    * **requirements** :: [`t:release_requirement/0`]
    * **updated_at** :: [`t:Aura.Model.Common.updated_at/0`]
    * **url** :: [`t:Aura.Model.Common.url/0`]
    * **version** :: [`t:Aura.Common.release_version/0`]

  ### 💻 Examples

  ```elixir
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
  ```

  #{Aura.Doc.related(["`Aura.Releases`"])}

  <!-- tabs-close -->
  """
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

  @doc """
  Builds a `HexRelease` from a map

  <!-- tabs-open -->

  ### 🏷️ Params
    * **m** :: A map to build into a `t:Aura.Model.HexRelease.t/0`

  <!-- tabs-close -->
  """
  @spec build(m :: map) :: HexRelease.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> Map.new(fn {k, v} -> {k, serialize(k, v)} end)
    |> Enum.reject(fn {_k, v} -> v == nil end)
    |> then(&Kernel.struct(HexRelease, &1))
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
