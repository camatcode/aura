# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexUser do
  @moduledoc """
  A struct defining a User for a Hex-compliant API
  """

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexUser

  @typedoc """
  Type defining a User for a Hex-compliant API

  <!-- tabs-open -->
  ### 🏷️ Keys
    * **username** :: `t:Aura.Common.username/0`
    * **email** ::  `t: Aura.Common.email/0`
    * **inserted_at** :: `t:Aura.Model.Common.inserted_at/0`
    * **updated_at** :: `t:Aura.Model.Common.updated_at/0`
    * **url** :: `t:Aura.Model.Common.url/0`

  <!-- tabs-close -->
  """
  @type t :: %HexUser{
          username: Aura.Common.username(),
          email: Aura.Common.email(),
          inserted_at: Common.inserted_at(),
          updated_at: Common.updated_at(),
          url: Common.url()
        }

  defstruct [
    :username,
    :email,
    :inserted_at,
    :updated_at,
    :url
  ]

  @doc """
  Builds a `HexUser` from a map
  """
  @spec build(m :: map) :: HexUser.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&struct(HexUser, &1))
  end
end
