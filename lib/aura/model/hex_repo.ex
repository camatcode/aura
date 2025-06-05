# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexRepo do
  @moduledoc Aura.Doc.mod_doc(
               [
                 "A struct describing a repository from a Hex-compliant API.",
                 "The main Hex.pm public repo is named `\"hexpm\"`; though private repos do exist."
               ],
               example: """
               %Aura.Model.HexRepo{
                name: "hexpm",
                public: nil,
                active: nil,
                billing_active: nil,
                inserted_at: ~U[2025-05-29 18:15:18.185511Z],
                updated_at: ~U[2025-05-29 18:15:18.185511Z]
               }
               """,
               related: [Aura.Repos]
             )
  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexRepo

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

  @enforce_keys [:name]

  defstruct [
    :name,
    :public,
    :active,
    :billing_active,
    :inserted_at,
    :updated_at
  ]

  @typedoc """
  Type describing a repository from a Hex-compliant API.

  <!-- tabs-open -->
  ### 🏷️ Required Keys
    * **name** :: `t:Aura.Common.repo_name/0`

  ### 🏷️ Optional Keys
    * **public** ::  `t:public?/0`
    * **active** :: `t:active?/0`
    * **billing_active** :: `t:billing_active?/0`
    * **inserted_at** :: `t:Aura.Model.Common.inserted_at/0`
    * **updated_at** :: `t:Aura.Model.Common.updated_at/0`

  ### 💻 Examples

  ```elixir
  %Aura.Model.HexRepo{
   name: "hexpm",
   public: nil,
   active: nil,
   billing_active: nil,
   inserted_at: ~U[2025-05-29 18:15:18.185511Z],
   updated_at: ~U[2025-05-29 18:15:18.185511Z]
  }
  ```
  <!-- tabs-close -->
  """
  @type t :: %HexRepo{
          name: Aura.Common.repo_name(),
          public: public?(),
          active: active?(),
          billing_active: billing_active?(),
          inserted_at: Common.inserted_at(),
          updated_at: Common.updated_at()
        }

  @doc """
  Builds a `HexRepo` from a map

  <!-- tabs-open -->

  ### 🏷️ Params
    * **m** :: A map to build into a `t:Aura.Model.HexRepo.t/0`

  <!-- tabs-close -->
  """
  @spec build(m :: map) :: HexRepo.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&struct(HexRepo, &1))
  end
end
