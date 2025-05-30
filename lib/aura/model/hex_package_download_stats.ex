# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexPackageDownloadStats do
  @moduledoc false

  import Aura.Model.Common

  alias Aura.Model.HexPackageDownloadStats

  defstruct all: 0,
            week: 0,
            day: 0

  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&struct(HexPackageDownloadStats, &1))
  end
end
