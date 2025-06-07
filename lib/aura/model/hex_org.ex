defmodule Aura.Model.HexOrg do
  @moduledoc Aura.Doc.mod_doc("Struct defining a Hex organization",
               example: """
               %Aura.Model.HexOrg{
                billing_active: false,
                inserted_at: ~U[2025-06-06 21:19:19.530971Z],
                name: "my_org",
                updated_at: ~U[2025-06-06 21:19:19.530971Z]
               }
               """
             )
  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexOrg

  @typedoc Aura.Doc.type_doc("Type describing a Hex organization",
             keys: %{
               billing_active: Aura.Model.Common,
               name: {Aura.Common, :org_name},
               inserted_at: Aura.Model.Common,
               updated_at: Aura.Model.Common
             },
             example: """
             %Aura.Model.HexOrg{
              billing_active: false,
              inserted_at: ~U[2025-06-06 21:19:19.530971Z],
              name: "my_org",
              updated_at: ~U[2025-06-06 21:19:19.530971Z]
             }
             """,
             related: [Aura.Orgs]
           )
  @type t :: %HexOrg{
          billing_active: Common.billing_active(),
          name: Aura.Common.org_name(),
          inserted_at: Common.inserted_at(),
          updated_at: Common.updated_at()
        }
  defstruct [
    :billing_active,
    :inserted_at,
    :name,
    :updated_at
  ]

  @doc Aura.Doc.func_doc("Builds a `HexOrg` from a map",
         params: %{m: "A map to build into a `t:Aura.Model.HexOrg.t/0`"}
       )
  @spec build(m :: map) :: HexOrg.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&struct(HexOrg, &1))
  end
end
