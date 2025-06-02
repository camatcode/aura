# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexAPIKey do
  @moduledoc """
  A struct describing an API key record coming from a Hex-compliant API.

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  %Aura.Model.HexAPIKey{
    authing_key: false,
    secret: "3321e19a16017725ced9fe56a0071aa6",
    inserted_at: ~U[2025-06-02 04:26:33.915977Z],
    name: "veniam.ut",
    permissions: [
      %{domain: "api", resource: "read"},
      %{domain: "api", resource: "write"}
    ],
    revoked_at: nil,
    updated_at: ~U[2025-06-02 04:26:33.915977Z],
    url: "http://localhost:4000/api/keys/veniam.ut"
  }
  ```

  #{Aura.Doc.related(["`Aura.Repos`"])}

  #{Aura.Doc.resources()}

  <!-- tabs-close -->
  """

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexAPIKey

  @typedoc """
  The API key payload - it is only provided once, upon creation; always `nil` after.

  > #### 🔒 Security {: .warning}
  >
  > Guard this secret payload with your life - **never** keep it as plain text in your code.

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "3321e19a16017725ced9fe56a0071aa6"
  ```

  #{Aura.Doc.related(["`Aura.Repos`"])}

  <!-- tabs-close -->
  """
  @type secret :: String.t() | nil

  @typedoc """
  ❓ Sorry, documentation from the hex specification is lacking here. ❓

  <!-- tabs-open -->

  #{Aura.Doc.resources()}

  #{Aura.Doc.related(["`Aura.Repos`"])}

  <!-- tabs-close -->
  """
  @type authing_key :: boolean()

  @typedoc """
  A permission realm that this API key has.

  <!-- tabs-open -->
  ### 🏷️ Keys
    * **domain** :: A domain for which this API key is valid
    * **resource** :: What kind of operations this API key can do within its domain

  ### 💻 Examples

  ```elixir
  %{domain: "api", resource: "read"}
  %{domain: "api", resource: "write"}
  ```
    
  #{Aura.Doc.related(["`Aura.Repos`"])}

  <!-- tabs-close -->  
  """
  @type api_permission :: %{domain: String.t(), resource: String.t()}

  @typedoc """
  `DateTime` when this key became invalid

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  ~U[2025-05-29 18:15:18.244790Z]
  ```

  #{Aura.Doc.related(["`Aura.Repos`"])}
    
  <!-- tabs-close -->
  """
  @type revoked_date_time :: DateTime.t() | nil

  @typedoc """
  Type describing an API key coming from a Hex-compliant API.

  <!-- tabs-open -->
  ### 🏷️ Keys
    * **authing_key** :: `t:authing_key/0`
    * **secret** :: `t:secret/0`
    * **inserted_at** :: `t:Aura.Model.Common.inserted_at/0`
    * **name** :: `t:Aura.Common.api_key_name/0`
    * **permissions** :: [`t:api_permission/0`]
    * **revoked_date_time** :: `t:revoked_date_time/0`
    * **updated_at** :: `t:Aura.Model.Common.updated_at/0`
    * **url** :: `t:Aura.Model.Common.url/0`

  ### 💻 Examples

  ```elixir
  %Aura.Model.HexAPIKey{
    authing_key: false,
    secret: "3321e19a16017725ced9fe56a0071aa6",
    inserted_at: ~U[2025-06-02 04:26:33.915977Z],
    name: "veniam.ut",
    permissions: [
      %{domain: "api", resource: "read"},
      %{domain: "api", resource: "write"}
    ],
    revoked_at: nil,
    updated_at: ~U[2025-06-02 04:26:33.915977Z],
    url: "http://localhost:4000/api/keys/veniam.ut"
  }
  ```

  #{Aura.Doc.related(["`Aura.Repos`"])}

  <!-- tabs-close -->
  """
  @type t :: %HexAPIKey{
          authing_key: authing_key(),
          secret: secret(),
          inserted_at: Common.inserted_at(),
          name: Aura.Common.api_key_name(),
          permissions: [api_permission()],
          revoked_at: revoked_date_time(),
          updated_at: Common.updated_at(),
          url: Common.url()
        }

  defstruct [
    :authing_key,
    :secret,
    :inserted_at,
    :name,
    :permissions,
    :revoked_at,
    :updated_at,
    :url
  ]

  @doc """
  Builds a `HexAPIKey` from a map

  <!-- tabs-open -->

  ### 🏷️ Params
    * **m** :: A map to build into a `t:Aura.Model.HexAPIKey.t/0`

  <!-- tabs-close -->
  """
  @spec build(m :: map) :: HexAPIKey.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> Enum.map(fn {k, v} -> {k, serialize(k, v)} end)
    |> then(&struct(HexAPIKey, &1))
  end

  defp serialize(_k, nil), do: nil

  defp serialize(:permissions, v) do
    v
    |> Enum.map(&prepare/1)
    |> Enum.map(&Map.new/1)
  end

  defp serialize(_k, v), do: v
end
