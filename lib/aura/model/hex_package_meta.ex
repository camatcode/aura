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

  @typedoc Aura.Doc.type_doc("Additional external URL relating to the package",
             example: """
             "https://github.com/michalmuskala/jason"
             """,
             related: [Aura.Packages, Aura.Releases]
           )
  @type meta_url :: URI.t()

  @typedoc Aura.Doc.type_doc("The software license associated to the package",
             example: """
             "Apache-2.0"
             """,
             related: [Aura.Packages, Aura.Releases]
           )
  @type software_license :: String.t()

  @typedoc Aura.Doc.type_doc("Short, human-readable description of the package",
             example: """
             "A blazing fast JSON parser and generator in pure Elixir."
             """,
             related: [Aura.Packages, Aura.Releases]
           )
  @type package_description :: String.t()

  @typedoc Aura.Doc.type_doc("Additional URLs associated with the Hex package",
             example: """
             %{"GitHub" => "https://github.com/michalmuskala/jason"}
             """,
             related: [Aura.Packages, Aura.Releases]
           )
  @type additional_links :: %{String.t() => meta_url()}

  @typedoc Aura.Doc.type_doc("Type describing additional metadata about a `Aura.Model.HexPackage`",
             keys: %{
               maintainers: {Aura.Common, :username, :list},
               links: {Aura.Model.HexPackageMeta, :additional_links},
               licenses: {Aura.Model.HexPackageMeta, :software_license, :list},
               description: {Aura.Model.HexPackageMeta, :package_description}
             },
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

  @doc Aura.Doc.func_doc("Builds a `HexPackageMeta` from a map",
         params: %{m: "A map to build into a `t:Aura.Model.HexPackageMeta.t/0`"}
       )
  @spec build(m :: map) :: HexPackageMeta.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&struct(HexPackageMeta, &1))
  end
end
