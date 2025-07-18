# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexAPIKey do
  @moduledoc Aura.Doc.mod_doc(
               "A struct describing an API key record coming from a Hex-compliant API.",
               example: """
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
               """,
               related: [Aura.APIKeys]
             )

  import Aura.Model.Common

  alias Aura.Model.Common
  alias Aura.Model.HexAPIKey

  @typedoc Aura.Doc.type_doc("The API key payload - it is only provided once, upon creation; always `nil` after.",
             example: """
             "3321e19a16017725ced9fe56a0071aa6"
             """,
             warning:
               {"🔒 Security", "Guard this secret payload with your life - **never** keep it as plain text in your code."},
             related: [Aura.APIKeys]
           )
  @type secret :: String.t() | nil

  @typedoc Aura.Doc.type_doc("Whether this key is the one currently being used to make authenticated requests",
             related: [Aura.APIKeys]
           )
  @type authing_key :: boolean()

  @typedoc Aura.Doc.type_doc("A domain for which this API key is valid")
  @type domain :: String.t()

  @typedoc Aura.Doc.type_doc("What kind of operations this API key can do within its domain")
  @type resource :: String.t()

  @typedoc Aura.Doc.type_doc("A permission realm belonging to this API key",
             keys: %{domain: HexAPIKey, resource: HexAPIKey},
             example: """
               %{domain: "api", resource: "read"}
               %{domain: "api", resource: "write"}
             """,
             related: [Aura.APIKeys]
           )
  @type api_permission :: %{domain: String.t(), resource: String.t()}

  @typedoc Aura.Doc.type_doc("`DateTime` when this key became invalid",
             example: """
             ~U[2025-05-29 18:15:18.244790Z]
             """,
             related: [Aura.APIKeys]
           )
  @type revoked_date_time :: DateTime.t() | nil

  @typedoc Aura.Doc.type_doc("Type describing an API key coming from a Hex-compliant API.",
             keys: %{
               authing_key: HexAPIKey,
               secret: HexAPIKey,
               inserted_at: Common,
               name: {Aura.Common, :api_key_name},
               permissions: {HexAPIKey, :api_permission, :list},
               revoked_at: {HexAPIKey, :revoked_date_time},
               updated_at: Common,
               url: Common
             },
             example: """
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
             """,
             related: [Aura.APIKeys]
           )
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

  @doc Aura.Doc.func_doc("Builds a `HexAPIKey` from a map",
         params: %{m: "A map to build into a `t:Aura.Model.HexAPIKey.t/0`"}
       )
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
