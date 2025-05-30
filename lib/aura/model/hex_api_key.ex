# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexAPIKey do
  @moduledoc false

  import Aura.Model.Common

  alias Aura.Model.HexAPIKey

  defstruct [
    :authing_key,
    :secret,
    :inserted_at,
    :name,
    :permissions,
    :revoked_at,
    :updated_at,
    :url
  ]

  def build(m) when is_map(m) do
    m
    |> prepare()
    |> Enum.map(fn {k, v} -> {k, serialize(k, v)} end)
    |> then(&struct(HexAPIKey, &1))
  end

  defp serialize(_k, nil), do: nil

  defp serialize(:permissions, v) do
    v
    |> Enum.map(&prepare/1)
    |> Enum.map(&Map.new/1)
  end

  defp serialize(_k, v), do: v
end
