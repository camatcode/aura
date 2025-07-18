# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexPackageOwner do
  @moduledoc Aura.Doc.mod_doc(
               "A struct describing an owner of a `Aura.Model.HexPackage`",
               example: """
               %Aura.Model.HexPackageOwner{
                email: "cam.cook.codes@gmail.com",
                full_name: "Cam Cook",
                handles: %{
                  elixir_forum: "https://elixirforum.com/u/camatcode",
                  git_hub: "https://github.com/camatcode"
                },
                inserted_at: ~U[2025-05-01 19:45:03.289458Z],
                level: :full,
                updated_at: ~U[2025-06-01 15:40:38.852881Z],
                url: "https://hex.pm/api/users/camatcode",
                username: "camatcode"
               }
               """,
               related: [Aura.Packages, Aura.Releases]
             )

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexPackageOwner

  @typedoc Aura.Doc.type_doc("The user's full name",
             example: """
             "Jane Smith"
             """,
             related: [Aura.Packages, Aura.Releases]
           )
  @type full_name :: String.t()

  @typedoc Aura.Doc.type_doc("A map of social media handles owned by this user",
             example: """
             %{
                git_hub: "https://github.com/michalmuskala",
                twitter: "https://twitter.com/michalmuskala",
                slack: "https://elixir-slackin.herokuapp.com/",
                libera: "irc://irc.libera.chat/elixir",
                elixir_forum: "https://elixirforum.com/u/michalmuskala"
             }
             """,
             related: [Aura.Packages, Aura.Releases]
           )
  @type social_handles :: %{
          elixir_form: URI.t(),
          git_hub: URI.t(),
          twitter: URI.t(),
          slack: URI.t(),
          libera: String.t()
        }

  @typedoc Aura.Doc.type_doc("The user's administration level for this package",
             related: [Aura.Packages, Aura.Releases]
           )
  @type level :: :full | :maintainer

  @typedoc Aura.Doc.type_doc("Type describing an owner of a `Aura.Model.HexPackage`",
             keys: %{
               email: Aura.Common,
               full_name: HexPackageOwner,
               handles: {HexPackageOwner, :social_handles},
               inserted_at: Common,
               level: HexPackageOwner,
               updated_at: Common,
               url: Common,
               username: Aura.Common
             },
             example: """
             %Aura.Model.HexPackageOwner{
              email: "cam.cook.codes@gmail.com",
              full_name: "Cam Cook",
              handles: %{
                elixir_forum: "https://elixirforum.com/u/camatcode",
                git_hub: "https://github.com/camatcode"
              },
              inserted_at: ~U[2025-05-01 19:45:03.289458Z],
              level: :full,
              updated_at: ~U[2025-06-01 15:40:38.852881Z],
              url: "https://hex.pm/api/users/camatcode",
              username: "camatcode"
             }
             """,
             related: [Aura.Packages, Aura.Releases]
           )
  @type t :: %HexPackageOwner{
          email: Aura.Common.email(),
          full_name: full_name(),
          handles: social_handles(),
          inserted_at: Common.inserted_at(),
          level: level(),
          updated_at: Common.updated_at(),
          url: Common.url(),
          username: Aura.Common.username()
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

  @doc Aura.Doc.func_doc("Builds a `HexPackageOwner` from a map",
         params: %{m: "A map to build into a `t:Aura.Model.HexPackageOwner.t/0`"}
       )
  @spec build(m :: map) :: HexPackageOwner.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> Enum.map(fn {k, v} -> {k, serialize(k, v)} end)
    |> then(&struct(HexPackageOwner, &1))
  end

  defp serialize(:handles, v), do: v |> prepare() |> Map.new()
  defp serialize(:level, v), do: String.to_atom(v)
  defp serialize(_k, v), do: v
end
