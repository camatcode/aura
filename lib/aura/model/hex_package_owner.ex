defmodule Aura.Model.HexPackageOwner do
  @moduledoc false

  import Aura.Model.Common

  alias Aura.Model.HexPackageOwner

  defstruct [
    :email,
    :full_name,
    :handles,
    :inserted_at,
    :level,
    :updated_at,
    :url,
    :username
  ]

  def build(m) when is_map(m) do
    m
    |> prepare()
    |> Enum.map(fn {k, v} -> {k, serialize(k, v)} end)
    |> then(&Kernel.struct(HexPackageOwner, &1))
  end

  defp serialize(_k, nil), do: nil

  defp serialize(:handles, v), do: v |> prepare() |> Map.new()

  defp serialize(:level, v), do: String.to_atom(v)

  defp serialize(_k, v), do: v
end
