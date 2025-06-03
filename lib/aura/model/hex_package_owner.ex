# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexPackageOwner do
  @moduledoc """
  A struct describing an owner of a `Aura.Model.HexPackage`

  <!-- tabs-open -->
  ### 💻 Examples

  ```elixir
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
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Releases`"])}

  #{Aura.Doc.resources()}
  <!-- tabs-close -->
  """

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexPackageOwner

  @typedoc """
  The user's full name

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "Jane Smith"
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Releases`"])}

  <!-- tabs-close -->
  """
  @type full_name :: String.t()

  @typedoc """
  A map of social media handles owned by this user

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  handles: %{
      git_hub: "https://github.com/michalmuskala",
      twitter: "https://twitter.com/michalmuskala",
      slack: "https://elixir-slackin.herokuapp.com/",
      libera: "irc://irc.libera.chat/elixir",
      elixir_forum: "https://elixirforum.com/u/michalmuskala"
  }
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Releases`"])}

  <!-- tabs-close -->
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
    * **email** :: `t:Aura.Common.email/0`
    * **full_name** ::  `t:full_name/0`
    * **handles** :: `t:social_handles/0`
    * **inserted_at** :: `t:Aura.Model.Common.inserted_at/0`
    * **level** :: `t:level/0`
    * **updated_at** :: `t:Aura.Model.Common.updated_at/0`
    * **url** :: `t:Aura.Model.Common.url/0`
   * **username** :: `t:Aura.Common.username/0`

  ### 💻 Examples

  ```elixir
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
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Releases`"])}

  <!-- tabs-close -->
  """
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

  @doc """
  Builds a `HexPackageOwner` from a map

  <!-- tabs-open -->

  ### 🏷️ Params
    * **m** :: A map to build into a `t:Aura.Model.HexPackageOwner.t/0`

  <!-- tabs-close -->
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
