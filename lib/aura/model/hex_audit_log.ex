# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexAuditLog do
  @moduledoc false

  import Aura.Model.Common

  alias Aura.Model.HexAuditLog

  defstruct [
    :action,
    :params,
    :user_agent
  ]

  def build(m) when is_map(m) do
    m
    |> prepare()
    |> Enum.map(fn {k, v} -> {k, serialize(k, v)} end)
    |> then(&struct(HexAuditLog, &1))
  end

  defp serialize(_k, nil), do: nil

  defp serialize(:params, v) do
    v
    |> prepare()
    |> Map.new()
  end

  defp serialize(_k, v), do: v
end
