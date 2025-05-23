defmodule Aura.Model.HexPackage do
  @moduledoc false

  import Aura.Model.Common

  alias Aura.Model.DownloadStats
  alias Aura.Model.HexPackage
  alias Aura.Model.PackageMeta
  alias Aura.Model.Release

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
    fields =
      m
      |> prepare()
      |> Enum.map(fn {k, v} -> {k, serialize(k, v)} end)

    struct(HexPackage, fields)
  end

  defp serialize(:meta, v), do: PackageMeta.build(v)
  defp serialize(:downloads, v), do: DownloadStats.build(v)

  defp serialize(:releases, v), do: Enum.map(v, &Release.build/1)

  defp serialize(_k, v), do: v
end

defmodule Aura.Model.PackageMeta do
  @moduledoc false

  import Aura.Model.Common

  defstruct [
    #
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

defmodule Aura.Model.Release do
  @moduledoc false

  import Aura.Model.Common

  defstruct [
    :version,
    :url
  ]

  def build(m) when is_map(m) do
    fields = prepare(m)
    struct(Aura.Model.Release, fields)
  end
end
