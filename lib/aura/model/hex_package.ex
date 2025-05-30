# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexPackage do
  @moduledoc false

  import Aura.Model.Common

  alias Aura.Model.HexPackage
  alias Aura.Model.HexPackageDownloadStats
  alias Aura.Model.HexPackageMeta
  alias Aura.Model.HexRelease

  HexPackageDownloadStats

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
