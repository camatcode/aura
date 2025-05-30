# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexAPIKey do
  @moduledoc """
  A struct describing an API key record coming from a Hex-compliant API.
  """

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexAPIKey

  @typedoc """
  The API key payload - it is only provided once, upon creation; always `nil` after
  """
  @type secret :: String.t() | nil

  @typedoc """
  ❓ Sorry, documentation from the hex specification is lacking here. ❓
  """
  @type authing_key :: boolean()

  @typedoc """
  A human-readable name for this API key (e.g `my_computer`)
  """
  @type api_key_name :: String.t()

  @typedoc """
  A permission realm that this API key has.

  <!-- tabs-open -->
  ### 🏷️ Keys
    * **domain** :: A domain for which this API key is valid
      * (e.g `"api"`, `"repository"`, `"repositories"`, `"package"`)
    * **resource** :: What kind of operations this API key can do within its domain
      * (e.g `"read"`, `"write"`)


  <!-- tabs-close -->
  """
  @type api_permission :: %{domain: String.t(), resource: String.t()}

  @typedoc """
  A Unix DateTime when this key became invalid
  """
  @type revoked_date_time :: DateTime.t() | nil

  @typedoc """
  Type describing an API key coming from a Hex-compliant API.

  <!-- tabs-open -->
  ### 🏷️ Keys
    * **authing_key** :: `t:authing_key/0`
    * **secret** :: `t:secret/0`
    * **inserted_at** :: `t:Aura.Model.Common.inserted_at/0`
    * **name** :: `t:api_key_name/0`
    * **permissions** :: [`t:api_permission/0`]
    * **revoked_date_time** :: `t:revoked_date_time/0`
    * **updated_at** :: `t:Aura.Model.Common.updated_at/0`
    * **url** :: `t:Aura.Model.Common.url/0`

  <!-- tabs-close -->
  """
  @type t :: %HexAPIKey{
          authing_key: authing_key(),
          secret: secret(),
          inserted_at: Common.inserted_at(),
          name: api_key_name(),
          permissions: [api_permission()],
          revoked_at: revoked_date_time(),
          updated_at: Common.updated_at(),
          url: Common.url()
        }

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

  @doc """
  Builds a `HexAPIKey` from a map
  """
  @spec build(m :: map) :: HexAPIKey.t()
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
