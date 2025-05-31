# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexPackageOwner do
  @moduledoc """
  A struct describing an owner of a `Aura.Model.HexPackage`
  """

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexPackageOwner

  @typedoc """
  The user's full name (e.g `"Jane Smith"`)
  """
  @type full_name :: String.t()

  @typedoc """
  A map of social media handles owned by this user
  """
  @type social_handles :: %{
          elixir_form: URI.t(),
          git_hub: URI.t(),
          twitter: URI.t(),
          slack: URI.t(),
          libera: String.t()
        }

  @typedoc """
  The user's administration level for this package
  """
  @type level :: :full | :maintainer

  @typedoc """
  Type describing an owner of a `Aura.Model.HexPackage`

  <!-- tabs-open -->
  ### 🏷️ Keys
    * **email** :: `t:Aura.Model.Common.email/0`
    * **full_name** ::  `t:full_name/0`
    * **handles** :: `t:social_handles/0`
    * **inserted_at** :: `t:Aura.Model.Common.inserted_at/0`
    * **level** :: `t:level/0`
    * **updated_at** :: `t:Aura.Model.Common.updated_at/0`
    * **url** :: `t:Aura.Model.Common.url/0`
   * **username** :: `t:Aura.Model.Common.username/0`

  <!-- tabs-close -->
  """
  @type t() :: %HexPackageOwner{
          email: Common.email(),
          full_name: full_name(),
          handles: social_handles(),
          inserted_at: Common.inserted_at(),
          level: level(),
          updated_at: Common.updated_at(),
          url: Common.url(),
          username: Common.username()
        }

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

  @doc """
  Builds a `HexPackageOwner` from a map
  """
  @spec build(m :: map) :: HexPackageOwner.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> Enum.map(fn {k, v} -> {k, serialize(k, v)} end)
    |> then(&Kernel.struct(HexPackageOwner, &1))
  end

  defp serialize(:handles, v), do: v |> prepare() |> Map.new()
  defp serialize(:level, v), do: String.to_atom(v)
  defp serialize(_k, v), do: v
end
