# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexAuditLog do
  @moduledoc """
  A struct describing a single auditable action from a Hex-compliant API.
  """

  import Aura.Model.Common

  alias Aura.Model.HexAuditLog

  @typedoc """
  A short description of the action taken. (e.g `"user.add"`, `"key.generate"`)
  """
  @type audit_action :: String.t()

  @typedoc """
  A map of all the details of an `t:audit_action/0`
  """
  @type audit_params :: map()

  @typedoc """
  The `User-Agent` provided in the HTTP headers relevant to the `t:audit_action/0`
  """
  @type user_agent :: String.t()

  @typedoc """
  Type describing an auditable action coming from a Hex-compliant API.

  <!-- tabs-open -->
  ### 🏷️ Keys
    * **action** :: `t:audit_action/0`
    * **params** :: `t:audit_params/0`
    * **user_agent** :: `t:user_agent/0`

  <!-- tabs-close -->
  """
  @type t :: %HexAuditLog{
          action: audit_action(),
          params: audit_params(),
          user_agent: user_agent()
        }

  defstruct [
    :action,
    :params,
    :user_agent
  ]

  @doc """
  Builds a `HexAuditLog` from a map
  """
  @spec build(m :: map) :: HexAuditLog.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> Enum.map(fn {k, v} -> {k, serialize(k, v)} end)
    |> then(&struct(HexAuditLog, &1))
  end

  defp serialize(:params, v) do
    v
    |> prepare()
    |> Map.new()
  end

  defp serialize(_k, v), do: v
end
