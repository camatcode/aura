defmodule Aura.Model.HexRelease do
  @moduledoc false

  import Aura.Model.Common

  defstruct [
    :checksum,
    :configs,
    :docs_html_url,
    :downloads,
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
    :url
  ]

  def build(m) when is_map(m) do
    fields =
      m
      |> prepare()
      |> Map.new(fn {k, v} -> {k, serialize(k, v)} end)

    struct(Aura.Model.HexRelease, fields)
  end

  defp serialize(_k, nil), do: nil
  defp serialize(:meta, v), do: v |> prepare() |> Map.new()
  defp serialize(:publisher, v), do: v |> prepare() |> Map.new()

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
