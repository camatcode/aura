# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexUser do
  @moduledoc Aura.Doc.mod_doc("A struct defining a User for a Hex-compliant API",
               example: """
               %Aura.Model.HexUser{
                 username: "alta2001",
                 email: "morgan.gulgowski@stehr.biz",
                 inserted_at: ~U[2025-06-04 00:53:31.880685Z],
                 updated_at: ~U[2025-06-04 00:53:31.880685Z],
                 url: "http://localhost:4000/api/users/alta2001"
               }
               """,
               related: [Aura.Users]
             )

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexUser

  @typedoc Aura.Doc.type_doc(
             "Type defining a User for a Hex-compliant API",
             keys: %{
               username: Aura.Common,
               email: Aura.Common,
               inserted_at: Aura.Model.Common,
               updated_at: Aura.Model.Common,
               url: Aura.Model.Common
             },
             example: """
             %Aura.Model.HexUser{
              username: "alta2001",
              email: "morgan.gulgowski@stehr.biz",
              inserted_at: ~U[2025-06-04 00:53:31.880685Z],
              updated_at: ~U[2025-06-04 00:53:31.880685Z],
              url: "http://localhost:4000/api/users/alta2001"
             }
             """
           )
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

  @doc Aura.Doc.func_doc("Builds a `HexUser` from a map",
         params: %{m: "A map to build into a `t:Aura.Model.HexUser.t/0`"}
       )
  @spec build(m :: map) :: HexUser.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&struct(HexUser, &1))
  end
end
