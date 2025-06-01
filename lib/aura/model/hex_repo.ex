# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexRepo do
  @moduledoc """
  A struct describing a repository from a Hex-compliant API.

  The main Hex.pm public repo is named `"hexpm"`; though private repos do exist.
  """

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexRepo

  @typedoc """
  The name of the repository (e.g `"hexpm"`)
  """
  @type repo_name :: String.t()

  @typedoc """
  Whether the repository is public
  """
  @type public? :: boolean()

  @typedoc """
  Whether the repository is active
  """
  @type active? :: boolean()

  @typedoc """
  Whether the repository is a billable entity
  """
  @type billing_active? :: boolean()

  defstruct [
    :name,
    :public,
    :active,
    :billing_active,
    :inserted_at,
    :updated_at
  ]

  @typedoc """
  Type a repository from a Hex-compliant API.

  <!-- tabs-open -->
  ### 🏷️ Keys
    * **name** :: `t:repo_name/0`
    * **public** ::  `t:public?/0`
    * **active** :: `t:active?/0`
    * **billing_active** :: `t:billing_active?/0`
    * **inserted_at** :: `t:Aura.Model.Common.inserted_at/0`
    * **updated_at** :: `t:Aura.Model.Common.updated_at/0`

  <!-- tabs-close -->
  """
  @type t :: %HexRepo{
          name: repo_name(),
          public: public?(),
          active: active?(),
          billing_active: billing_active?(),
          inserted_at: Common.inserted_at(),
          updated_at: Common.updated_at()
        }

  @doc """
  Builds a `HexRepo` from a map
  """
  @spec build(m :: map) :: HexRepo.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&Kernel.struct(HexRepo, &1))
  end
end
