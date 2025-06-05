# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexPackageMeta do
  @moduledoc Aura.Doc.mod_doc(
               "A struct describing additional metadata about a `Aura.Model.HexPackage`",
               example: """
               %Aura.Model.HexPackageMeta{
                maintainers: [],
                links: %{"GitHub" => "https://github.com/michalmuskala/jason"},
                licenses: ["Apache-2.0"],
                description: "A blazing fast JSON parser and generator in pure Elixir."
               }
               """,
               related: [Aura.Packages, Aura.Releases]
             )

  import Aura.Model.Common

  alias Aura.Model.HexPackageMeta

  @typedoc """
  Additional external URL relating to the package

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "https://github.com/michalmuskala/jason"
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Releases`"])}

  <!-- tabs-close -->
  """
  @type meta_url :: URI.t()

  @typedoc """
  The software license associated to the package

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "Apache-2.0"
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Releases`"])}

  <!-- tabs-close -->
  """
  @type software_license :: String.t()

  @typedoc """
  Short, human-readable description of the package

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "A blazing fast JSON parser and generator in pure Elixir."
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Releases`"])}

  <!-- tabs-close -->
  """
  @type package_description :: String.t()

  @typedoc """
  Type describing additional metadata about a `Aura.Model.HexPackage`

  <!-- tabs-open -->
  ### 🏷️ Keys
    * **maintainers** :: [`t:Aura.Common.username/0`]
    * **links** ::  [`t:meta_url/0`]
    * **licenses** :: [`t:software_license/0`]
    * **description** :: `t:package_description/0`

  ### 💻 Examples

  ```elixir
  %Aura.Model.HexPackageMeta{
     maintainers: [],
     links: %{"GitHub" => "https://github.com/michalmuskala/jason"},
     licenses: ["Apache-2.0"],
     description: "A blazing fast JSON parser and generator in pure Elixir."
   }
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Releases`"])}

  <!-- tabs-close -->
  """
  @type t :: %HexPackageMeta{
          maintainers: [Aura.Common.username()],
          links: %{String.t() => meta_url()},
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

  <!-- tabs-open -->

  ### 🏷️ Params
    * **m** :: A map to build into a `t:Aura.Model.HexPackageMeta.t/0`

  <!-- tabs-close -->
  """
  @spec build(m :: map) :: HexPackageMeta.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&struct(HexPackageMeta, &1))
  end
end
