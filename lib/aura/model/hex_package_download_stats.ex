# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexPackageDownloadStats do
  @moduledoc """
  A struct describing download stats associated to a `Aura.Model.HexPackage`

  <!-- tabs-open -->
  ### 💻 Examples

  ```elixir
  %Aura.Model.HexPackageDownloadStats{all: 196, week: 49, day: 49}
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Releases`"])}

  #{Aura.Doc.resources()}
  <!-- tabs-close -->
  """

  import Aura.Model.Common

  alias Aura.Model.HexPackageDownloadStats

  @typedoc """
  Number of downloads since the first release
  """
  @type all_time :: non_neg_integer()

  @typedoc """
  Number of downloads this week
  """
  @type this_week :: non_neg_integer()

  @typedoc """
  Number of downloads today
  """
  @type today :: non_neg_integer()

  @typedoc """
  Type describing the number of downloads for a `Aura.Model.HexPackage`

  <!-- tabs-open -->
  ### 🏷️ Keys
    * **all** :: `t:all_time/0`
    * **week** :: `t:this_week/0`
    * **day** :: `t:today/0`

  ### 💻 Examples

  ```elixir
  %Aura.Model.HexPackageDownloadStats{all: 196, week: 49, day: 49}
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Releases`"])}

  <!-- tabs-close -->
  """
  @type t :: %HexPackageDownloadStats{
          all: all_time(),
          week: this_week(),
          day: today()
        }

  defstruct all: 0,
            week: 0,
            day: 0

  @doc """
  Builds a `HexPackageDownloadStats` from a map

  <!-- tabs-open -->

  ### 🏷️ Params
    * **m** :: A map to build into a `t:Aura.Model.HexPackageDownloadStats.t/0`

  <!-- tabs-close -->
  """
  @spec build(m :: map) :: HexPackageDownloadStats.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&struct(HexPackageDownloadStats, &1))
  end
end
