defmodule Aura.Model.HexPackage do
  @moduledoc false

  import Aura.Model.Common

  alias Aura.Model.DownloadStats
  alias Aura.Model.HexPackage
  alias Aura.Model.HexRelease
  alias Aura.Model.PackageMeta

  DownloadStats

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
  defp serialize(:meta, v), do: PackageMeta.build(v)
  defp serialize(:downloads, v), do: DownloadStats.build(v)

  defp serialize(:releases, v), do: Enum.map(v, &HexRelease.build/1)

  defp serialize(_k, v), do: v
end

defmodule Aura.Model.PackageMeta do
  @moduledoc false

  import Aura.Model.Common

  defstruct [
    :maintainers,
    :links,
    :licenses,
    :description
  ]

  def build(m) when is_map(m) do
    fields = prepare(m)

    struct(Aura.Model.PackageMeta, fields)
  end
end

defmodule Aura.Model.DownloadStats do
  @moduledoc false

  import Aura.Model.Common

  defstruct all: 0,
            week: 0,
            day: 0

  def build(m) when is_map(m) do
    fields = prepare(m)
    struct(Aura.Model.DownloadStats, fields)
  end
end
