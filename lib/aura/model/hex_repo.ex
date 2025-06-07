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

  @typedoc Aura.Doc.type_doc("Whether the repository is public")
  @type public :: boolean()

  @typedoc Aura.Doc.type_doc("Whether the repository is active")
  @type active :: boolean()

  @enforce_keys [:name]

  defstruct [
    :name,
    :public,
    :active,
    :billing_active,
    :inserted_at,
    :updated_at
  ]

  @typedoc Aura.Doc.type_doc(
             "Type describing a repository from a Hex-compliant API.",
             keys: %{
               public: Aura.Model.HexRepo,
               active: Aura.Model.HexRepo,
               billing_active: Aura.Model.Common,
               inserted_at: Aura.Model.Common,
               updated_at: Aura.Model.Common
             },
             example: """
             %Aura.Model.HexRepo{
              name: "hexpm",
              public: nil,
              active: nil,
              billing_active: nil,
              inserted_at: ~U[2025-05-29 18:15:18.185511Z],
              updated_at: ~U[2025-05-29 18:15:18.185511Z]
             }
             """
           )
  @type t :: %HexRepo{
          name: Aura.Common.repo_name(),
          public: public(),
          active: active(),
          billing_active: Common.billing_active(),
          inserted_at: Common.inserted_at(),
          updated_at: Common.updated_at()
        }

  @doc Aura.Doc.func_doc("Builds a `HexRepo` from a map",
         params: %{m: "A map to build into a `t:Aura.Model.HexRepo.t/0`"}
       )
  @spec build(m :: map) :: HexRepo.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&struct(HexRepo, &1))
  end
end
