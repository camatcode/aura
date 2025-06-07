defmodule Aura.Model.HexOrgMember do
  @moduledoc Aura.Doc.mod_doc("Struct defining a member of a Hex organization",
               example: """
               %Aura.Model.HexOrgMember{
                email: "hello@hello.com",
                role: "admin",
                url: "http://localhost:4000/api/users/hello",
                username: "hello"
               }
               """,
               related: [Aura.Orgs]
             )

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexOrgMember

  @typedoc Aura.Doc.type_doc("Permission level of the org member",
             example: """
             :admin
             """,
             related: [Aura.Orgs]
           )
  @type role :: :admin | :read | :write

  @typedoc Aura.Doc.type_doc("Type describing an org member",
             keys: %{username: Aura.Common, email: Aura.Common, url: Common, role: HexOrgMember},
             example: """
             %Aura.Model.HexOrgMember{
              email: "hello@hello.com",
              role: "admin",
              url: "http://localhost:4000/api/users/hello",
              username: "hello"
             }
             """,
             related: [Aura.Orgs]
           )
  @type t :: %Aura.Model.HexOrgMember{
          username: Aura.Common.username(),
          email: Aura.Common.email(),
          url: Common.url(),
          role: role()
        }

  defstruct [
    :email,
    :role,
    :url,
    :username
  ]

  @doc Aura.Doc.func_doc("Builds a `HexOrgMember` from a map",
         params: %{m: "A map to build into a `t:Aura.Model.HexOrgMember.t/0`"}
       )
  @spec build(m :: map) :: HexOrgMember.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&struct(HexOrgMember, &1))
  end
end
