# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexAuditLog do
  @moduledoc Aura.Doc.mod_doc(
               "A struct describing a single auditable action from a Hex-compliant API.",
               example: """
               %Aura.Model.HexAuditLog{
                action: "user.create",
                params: %{id: 424, handles: nil, username: "jaqueline1935"},
                user_agent: "aura/0.9.0 (Elixir/1.18.3) (OTP/27.3.1) (test)"
               }
               """,
               related: [Aura.Packages, Aura.Users]
             )

  import Aura.Model.Common

  alias Aura.Model.HexAuditLog

  @typedoc """
  A short description of the action taken. (e.g `"user.add"`, `"key.generate"`)

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "docs.publish"
  "release.publish"
  "key.generate"
  "email.public"
  "email.primary"
  "email.add"
  "user.create"
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Users`"])}

  <!-- tabs-close -->
  """
  @type audit_action :: String.t()

  @typedoc """
  A map of all the details of an `t:audit_action/0`

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  %{
    package: %{
      "id" => 445,
      "meta" => %{
        "description" => "Ea laborum odio eveniet in pariatur doloribus vel ullam aut.",
        "extra" => nil,
        "licenses" => ["Apache-2.0"],
        "links" => %{"GitHub" => "http://marquardt.com"},
        "maintainers" => nil
      },
      "name" => "zontrax_576460749439376791"
      },
      release: %{
      "has_docs" => false,
      "id" => 544,
      "meta" => %{
        "app" => "zontrax_576460749439376791",
        "build_tools" => ["mix"],
        "elixir" => "~> 1.12"
      },
      "package_id" => 445,
      "retirement" => nil,
      "version" => "0.9.0"
      }
  }
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Users`"])}

  <!-- tabs-close -->
  """
  @type audit_params :: map()

  @typedoc """
  The `User-Agent` provided in the HTTP headers relevant to the `t:audit_action/0`

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "aura/0.9.0 (Elixir/1.18.3) (OTP/27.3.1) (test)"
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Users`"])}

  <!-- tabs-close -->
  """
  @type user_agent :: String.t()

  @typedoc """
  Type describing an auditable action coming from a Hex-compliant API.

  <!-- tabs-open -->
  ### 🏷️ Keys
    * **action** :: `t:audit_action/0`
    * **params** :: `t:audit_params/0`
    * **user_agent** :: `t:user_agent/0`

  ### 💻 Examples

  ```elixir
  %Aura.Model.HexAuditLog{
      action: "user.create",
      params: %{id: 424, handles: nil, username: "jaqueline1935"},
      user_agent: "aura/0.9.0 (Elixir/1.18.3) (OTP/27.3.1) (test)"
  }
  ```

  #{Aura.Doc.related(["`Aura.Packages`", "`Aura.Users`"])}

  <!-- tabs-close -->
  """
  @type t :: %HexAuditLog{
          action: audit_action(),
          params: audit_params(),
          user_agent: user_agent()
        }

  defstruct [
    :action,
    :params,
    :user_agent
  ]

  @doc """
  Builds a `HexAuditLog` from a map

  <!-- tabs-open -->

  ### 🏷️ Params
    * **m** :: A map to build into a `t:Aura.Model.HexAuditLog.t/0`

  <!-- tabs-close -->
  """
  @spec build(m :: map) :: HexAuditLog.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> Enum.map(fn {k, v} -> {k, serialize(k, v)} end)
    |> then(&struct(HexAuditLog, &1))
  end

  defp serialize(:params, v) do
    v
    |> prepare()
    |> Map.new()
  end

  defp serialize(_k, v), do: v
end
