# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexRelease do
  @moduledoc """
  A struct describing a single release of a `Aura.Model.HexPackage`
  """

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexRelease

  @typedoc """
  SHA-256 checksum of the associated release **tar.gz**
  """
  @type release_checksum :: String.t()

  @typedoc """
  A mapping between a build-tool config (e.g `"mix.exs"`), and the configuration needed to grab this release
  (e.g `"{:plug, "~> 0.8.3"}"`)
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
  """
  @type package_reference_url :: URI.t()

  @typedoc """
  The version of this release
  """
  @type release_version :: String.t()

  @typedoc """
  Additional information relevant to the release
  (e.g `%{elixir: nil, app: "decimal", build_tools: ["mix"]}`)
  """
  @type release_meta :: map()

  @typedoc """
  Information about the user which published this release
    (e.g `%{url: (users url), username: "eric", email: "eric@example.com"}`)
  """
  @type release_publisher :: map()

  @typedoc """
  A dependency of this release (e.g `%{optional: false, app: "my_package", requirement: "~> 2.11.52"}`
  """
  @type release_requirement :: map()

  @typedoc """
  Whether this release is considered retired
  """
  @type retired? :: boolean()

  @typedoc """
  Type describing an owner of a `Aura.Model.HexRelease`

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
          version: release_version()
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
