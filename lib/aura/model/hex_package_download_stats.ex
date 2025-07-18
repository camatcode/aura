# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexPackageDownloadStats do
  @moduledoc Aura.Doc.mod_doc(
               "A struct describing download stats associated to a `Aura.Model.HexPackage`",
               example: """
               %Aura.Model.HexPackageDownloadStats{all: 196, week: 49, day: 49}
               """,
               related: [Aura.Packages, Aura.Releases]
             )

  import Aura.Model.Common

  alias Aura.Model.HexPackageDownloadStats

  @typedoc Aura.Doc.type_doc("Number of downloads since the first release")
  @type all_time :: non_neg_integer()

  @typedoc Aura.Doc.type_doc("Number of downloads this week")
  @type this_week :: non_neg_integer()

  @typedoc Aura.Doc.type_doc("Number of downloads today")
  @type today :: non_neg_integer()

  @typedoc Aura.Doc.type_doc("Type describing the number of downloads for a `Aura.Model.HexPackage`",
             keys: %{
               all: {HexPackageDownloadStats, :all_time},
               week: {HexPackageDownloadStats, :this_week},
               day: {HexPackageDownloadStats, :today}
             },
             example: """
             %Aura.Model.HexPackageDownloadStats{all: 196, week: 49, day: 49}
             """,
             related: [Aura.Packages, Aura.Releases]
           )
  @type t :: %HexPackageDownloadStats{
          all: all_time(),
          week: this_week(),
          day: today()
        }

  defstruct all: 0,
            week: 0,
            day: 0

  @doc Aura.Doc.func_doc("Builds a `HexPackageDownloadStats` from a map",
         params: %{m: "A map to build into a `t:Aura.Model.HexPackageDownloadStats.t/0`"}
       )
  @spec build(m :: map) :: HexPackageDownloadStats.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&struct(HexPackageDownloadStats, &1))
  end
end
